using ari;

namespace bh.game
{
	public enum BlockType
	{
		Box,
		Z,
		RZ,
		T,
		L,
		RL,
		I
	}

	public enum Direction
	{
	    North,
	    East,
	    South,
	    West
	}

	public class Block : Entity
	{
		Vector2[4] blocks;
		BlockType block_type;
		Direction direction = .North;

		public const float BlockSize = 32.0f;
		public const float BlockSizeHalf = BlockSize / 2.0f;
		public const float BlockOffsetx = 5;

		Sprite2D[] sprites = new Sprite2D[4];
		static TextureHandle block_texture = .();

		// Block position
		Vector2 position;

		Map map;

		this(EntityHandle _handle) : base(_handle)
		{
			LoadTexture();
		}

		public static void LoadTexture()
		{
			if (block_texture.Handle == uint32.MaxValue)
			{
				block_texture = Gfx.LoadTexture("res:block.png");
			}
		}

		public ~this()
		{
			for (int i = 0; i < 4; i++)
				if (sprites[i] != null)
					delete sprites[i];
			delete sprites;
		}

		void UpdateBlockPos()
		{
			switch(block_type)
			{
			case .Box:
				blocks[0].x = blocks[2].x = 0.0f;			//	[2][3]
				blocks[1].x = blocks[3].x = 1.0f;			//	[0][1]
				blocks[0].y = blocks[1].y = 0.0f;
				blocks[2].y = blocks[3].y = 1.0f;
			case .Z:
				if (direction == .North || direction == .South)
				{
					blocks[0].x = -1.0f;					//	[0][1]
					blocks[1].x = blocks[2].x = 0.0f;		//	   [2][3]
					blocks[3].x = 1.0f;
					blocks[0].y = blocks[1].y = 1.0f;
					blocks[2].y = blocks[3].y = 0.0f;
				}
				else
				{
					blocks[0].x = blocks[1].x = 0;			//	   [0]
					blocks[2].x = blocks[3].x = -1;			//	[2][1]
					blocks[1].y = blocks[2].y = 0.0f;		//  [3]
					blocks[3].y = -1;
					blocks[0].y = 1.0f;
				}
			case .RZ:
				if (direction == .North || direction == .South)
				{
					blocks[0].x = -1.0f;					//	   [2][3]	
					blocks[1].x = blocks[2].x = 0.0f;		//	[0][1]
					blocks[3].x = 1.0f;
					blocks[0].y = blocks[1].y = 0.0f;
					blocks[2].y = blocks[3].y = 1.0f;
				}
				else
				{
					blocks[3].x = blocks[2].x = 0;			//	   [3]
					blocks[1].x = blocks[0].x = 1;			//	   [2][1]
					blocks[1].y = blocks[2].y = 0.0f;		//  	  [0]
					blocks[0].y = -1;
					blocks[3].y = 1.0f;
				}
			case .T:
				switch (direction)
				{
				case .North:
					blocks[0].x = -1.0f;					//	[0][1][2]
					blocks[1].x = blocks[3].x = 0.0f;		//	   [3]
					blocks[2].x = 1.0f;
					blocks[0].y = blocks[1].y = blocks[2].y = 0;
					blocks[3].y = -1;
				case .East:
					blocks[0].x = blocks[1].x = blocks[2].x =  0;					
					blocks[3].x = -1;						//	   [0]
					blocks[0].y = 1;						//	[3][1]
					blocks[1].y = blocks[3].y = 0;			//     [2]
					blocks[2].y = -1;
				case .South:
					blocks[0].x = -1.0f;					//	   [3]
					blocks[1].x = blocks[3].x = 0.0f;		//	[0][1][2]
					blocks[2].x = 1.0f;
					blocks[0].y = blocks[1].y = blocks[2].y = 0;
					blocks[3].y = 1;
				case .West:
					blocks[0].x = blocks[1].x = blocks[2].x =  0;					
					blocks[3].x = 1;						//	   [0]
					blocks[0].y = 1;						//     [1][3]
					blocks[1].y = blocks[3].y = 0;			//     [2]
					blocks[2].y = -1;
				}
			case .L:
				switch (direction)
				{
				case .North:
					blocks[0].x = blocks[1].x = blocks[2].x = 0.0f;
					blocks[3].x = 1.0f;						//	[0]
					blocks[0].y = 1;						//	[1]
					blocks[1].y = 0;						//	[2][3]
					blocks[2].y = blocks[3].y = -1;
				case .East:
					blocks[2].x = blocks[3].x = -1;			//	[2][1][0]
					blocks[1].x = 0;						//	[3]
					blocks[0].x = 1;
					blocks[0].y = blocks[1].y = blocks[2].y = 0;
					blocks[3].y = -1;
				case .South:
					blocks[0].x = blocks[1].x = blocks[2].x = 0.0f;
					blocks[3].x = -1;						//	[3][0]
					blocks[2].y = -1;						//	   [1]
					blocks[1].y = 0;						//	   [2]
					blocks[0].y = blocks[3].y = 1;
				case .West:
					blocks[0].x = blocks[3].x = 1;			//	      [3]
					blocks[1].x = 0;						//	[2][1][0]
					blocks[2].x = -1;
					blocks[0].y = blocks[1].y = blocks[2].y = 0;
					blocks[3].y = 1;
				}
			case .RL:
				switch (direction)
				{
				case .North:
					blocks[0].x = blocks[1].x = blocks[2].x = 0.0f;
					blocks[3].x = -1.0f;					//	   [0]
					blocks[0].y = 1.0f;						//	   [1]
					blocks[1].y = 0.0f;						// 	[3][2]
					blocks[2].y = blocks[3].y = -1.0f;
				case .East:
					blocks[0].x = 1;						//	[3]
					blocks[1].x = 0;						//	[2][1][0]
					blocks[2].x = blocks[3].x = -1;
					blocks[0].y = blocks[1].y = blocks[2].y = 0;
					blocks[3].y = 1;
				case .South:
					blocks[0].x = blocks[1].x = blocks[2].x = 0.0f;
					blocks[3].x = 1;						//	   [0][3]
					blocks[2].y = -1;						//	   [1]
					blocks[1].y = 0;						//	   [2]
					blocks[0].y = blocks[3].y = 1;
				case .West:
					blocks[2].x = -1;						//	[2][1][0]
					blocks[1].x = 0;						//		  [3]
					blocks[0].x = blocks[3].x = 1;
					blocks[0].y = blocks[1].y = blocks[2].y = 0;
					blocks[3].y = -1;
				}
			case .I:
				if (direction == .North || direction == .South)
				{
					blocks[0].y = blocks[1].y = blocks[2].y = blocks[3].y = 0.0f;
					blocks[0].x = -1.0f;					//	[0][1][2][3]
					blocks[1].x = 0.0f;
					blocks[2].x = 1.0f;
					blocks[3].x = 2.0f;
				}
				else
				{
					blocks[0].x = blocks[1].x = blocks[2].x = 0.0f;
					blocks[3].x = 0;						//	   [0]
					blocks[0].y = 2.0f;						//	   [1]
					blocks[1].y = 1.0f;						// 	   [2]
					blocks[2].y = 0.0f;						//	   [3]
					blocks[3].y = -1;
				}
			}

			// Set the sprite pos
			for (int i = 0; i < 4; i++)
			{
				*sprites[i].Position = (blocks[i] + position) * BlockSize + BlockSizeHalf;
				sprites[i].Position.x += BlockOffsetx;
				if (sprites[i].Scale.x < BlockSize)
				{
					let x = BlockSize - sprites[i].Scale.x;
					sprites[i].Position.x -= blocks[i].x * x + x ;
					sprites[i].Position.y -= blocks[i].y * x - x * 3;
				}
			}
		}

		public static Sprite2D CreateBlockSprite()
		{
			var s = World.CreateSprite2D();
			s.Scale.Set(BlockSize);
			*s.Texture = block_texture;
			return s;
		}

		public void SetScale(float blockSize)
		{
			for (int i = 0; i < 4; i++)
				sprites[i].Scale.Set(blockSize);
		}

		// This is used in next block view
		public void SetType(BlockType _block_type)
		{
			block_type = _block_type;

			Color block_color;
			switch(block_type)
			{
			case .Box: block_color = Color.YELLOW; direction = .North;
			case .I: block_color = Color.SKYBLUE; direction = .North;
			case .L: block_color = Color.PINK; direction = .East;
			case .RL: block_color = Color.VIOLET; direction = .West;
			case .RZ: block_color = Color.MAGENTA; direction = .North;
			case .T: block_color = Color.PURPLE; direction = .North;
			case .Z: block_color = Color.RED; direction = .North;
			}

			// Create components
			for (int i = 0; i < 4; i++)
			{
				*sprites[i].Color = block_color;
			}

			UpdateBlockPos();

		}

		// Create components, Add them to world
		public void Init(World _world, BlockType _block_type, Vector2 _pos, Map _map)
		{
			position = _pos;
			map = _map;

			// Create components
			for (int i = 0; i < 4; i++)
			{
				sprites[i] = CreateBlockSprite();
				_world.AddComponent(this, sprites[i]);
			}

			SetType(_block_type);

			// Add entity to world
			_world.AddEntity(this);
		}

		// return false when can not move
		public bool HandleInput(KeyType _key)
		{
			switch (_key)
			{
			case .RotateCW:
				switch (direction)
				{
				case .North: direction = .East;
				case .East: direction = .South;
				case .South: direction = .West;
				case .West: direction = .North;
				}
			case .RotateCCW:
				switch (direction)
				{
				case .North: direction = .West;
				case .East: direction = .North;
				case .South: direction = .East;
				case .West: direction = .South;
				}
			case .Down: position.y -= 1.0f;
			case .Left: position.x -= 1.0f;
			case .Right: position.x += 1.0f;
			case .Drop: while (HandleInput(.Down)) { } return false;
			default:
			}

			UpdateBlockPos();

			// check for collision
			let collide = map.Collide(blocks, position);
			if (collide != .NoCollid)
			{
				// it collide something

				// Revert position
				switch (_key)
				{
				case .RotateCW:
					if (collide == .Left && HandleInput(.Right))
					{

					}
					else if(collide == .Right && HandleInput(.Left))
					{

					}
					else
					{
						switch (direction)
						{
						case .North: direction = .West;
						case .East: direction = .North;
						case .South: direction = .East;
						case .West: direction = .South;
						}
					}
				case .RotateCCW:
					if (collide == .Left && HandleInput(.Right))
					{

					}
					else if(collide == .Right && HandleInput(.Left))
					{

					}
					else
					{
						switch (direction)
						{
						case .North: direction = .East;
						case .East: direction = .South;
						case .South: direction = .West;
						case .West: direction = .North;
						}
					}
				case .Down: position.y += 1.0f;
				case .Left: position.x += 1.0f;
				case .Right: position.x -= 1.0f;
				default:
				}

				UpdateBlockPos();

				if (_key == .Down)
				{
					// It reaches bottom of map
					map.BlockReachedToEnd();
				}
				return false;

			}

			return true;
		}
	}
}
