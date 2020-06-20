using ari;
using ari.user;
using bh.game;
using System;
using System.Collections;
using bh.net;
using bh.gui;

namespace bh
{
	public class GameApp: Application
	{
		// Engine stuffs
		World world = new World();
		RenderSystem2D render_system = new RenderSystem2D();
		SceneSystem2D scene_system = new SceneSystem2D();
		FileSystemLocal _fs = new FileSystemLocal();
		float touch_x;
		float touch_y;
		float total_time = 0;
		float touch_start_time;
		bool MovedWithTouch;
		bool MovedDownWithTouch;

		// network
#if ARI_SERVER
		ServerSystem network = new ServerSystem();
#else
		ClientSystem network = new ClientSystem();
#endif
		NetworkManager netManager;
		String IP = "127.0.0.1";//"104.244.75.183";
		int32 Port = 55223;

		// Profile server
		ProfileServer profile_server = null ~ delete _;

		// Game stuff
		MainMenu main_menu;

		public this()
		{
			setup = new GfxSetup();
			setup.window.Width = 660;
			setup.window.Height = 640;
			setup.window.HighDpi = true;
			setup.swap_interval = 1;
			// warning: Don't initialize anything here use OnInit function.
		}

		public override void OnInit()
		{
			base.OnInit();

			// Set clear color
			Color clear_color = .(72, 78, 112, 255);
			Gfx.SetClearColor(ref clear_color);

			// Add systems
			world.AddSystem(render_system);
			world.AddSystem(scene_system);
			world.AddSystem(network);

			// Initialize network
			Net.InitNetwork();
#if ARI_SERVER
			network.CreateServer(IP, Port);
#endif

			netManager = new NetworkManager(network, world);

			Io.RegisterFileSystem("file", _fs);

			// Profile server
			profile_server = new ProfileServer("https://localhost:44327/api/")

			// Game stuff
			main_menu = World.CreateEntity<MainMenu>();
			main_menu.Init(world);
			main_menu.OnSinglePlayerClick = new => OnSinglePlayerClicked;
			main_menu.OnMultiPlayerClick = new => OnMultiPlayerClicked;
		}

		public override void OnFrame(float _elapsedTime)
		{
			total_time += _elapsedTime;
			base.OnFrame(_elapsedTime);
			netManager.Update(_elapsedTime);
			world.Update(_elapsedTime);
		}

		public override void OnEvent(ari_event* _event, ref WindowHandle _handle)
		{
			base.OnEvent(_event, ref _handle);
			if (main_menu != null)
				main_menu.OnEvent(_event);

			if (_event.type == .ARI_EVENTTYPE_KEY_DOWN)
			{
				if (_event.key_code == .ARI_KEYCODE_UP)
					netManager.HandleInput(.RotateCW);
				if (_event.key_code == .ARI_KEYCODE_LEFT)
					netManager.HandleInput(.Left);
				if (_event.key_code == .ARI_KEYCODE_RIGHT)
					netManager.HandleInput(.Right);
				if (_event.key_code == .ARI_KEYCODE_DOWN)
					netManager.HandleInput(.Down);
				if (_event.key_code == .ARI_KEYCODE_SPACE)
					netManager.HandleInput(.Drop);
			}
			else if (_event.type == .ARI_EVENTTYPE_TOUCHES_BEGAN)
			{
				touch_x = _event.touches[0].pos_x;
				touch_y = _event.touches[0].pos_y;
				MovedWithTouch = false;
				MovedDownWithTouch = false;
				touch_start_time = total_time;
			}
			else if (_event.type == .ARI_EVENTTYPE_TOUCHES_MOVED)
			{
				float dx = touch_x - _event.touches[0].pos_x;
				int w = _event.window_width / 15;
				if (dx > w)
				{
					touch_x = _event.touches[0].pos_x;
					netManager.HandleInput(.Left);
					MovedWithTouch = true;
				}
				else if (dx < -w)
				{
					touch_x = _event.touches[0].pos_x;
					netManager.HandleInput(.Right);
					MovedWithTouch = true;
				}
				else if (!MovedWithTouch && total_time - touch_start_time > 0.4f)
				{
					MovedDownWithTouch = true;
					netManager.HandleInput(.Down);
				}
			}
			else if (_event.type == .ARI_EVENTTYPE_TOUCHES_ENDED)
			{
				if (MovedWithTouch)
					return;
				float dx = touch_x - _event.touches[0].pos_x;
				float dy = touch_y - _event.touches[0].pos_y;
				if (dy < -200 && Math.Abs(dx) < 64)
					netManager.HandleInput(.Drop);
				else if (!MovedDownWithTouch && Math.Abs(dx) < 32)
					netManager.HandleInput(.RotateCW);
			}
		}

		void OnSinglePlayerClicked()
		{
			netManager.StartSinglePlayer();
			delete main_menu;
			main_menu = null;
		}

		void OnMultiPlayerClicked()
		{
#if !ARI_SERVER
			network.Connect(IP, Port);
#endif
			delete main_menu;
			main_menu = null;
		}

		public override void OnCleanup()
		{
			base.OnCleanup();
			delete render_system;
			delete scene_system;
			delete _fs;

			delete main_menu;

			delete netManager;

			network.Stop();
			delete network;
			Net.ShutdownNetwork();
			delete world;
		}
	}
}
