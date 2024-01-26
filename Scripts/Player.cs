using Godot;
using System;

public partial class Player : CharacterBody2D
{
	public const float Speed = 300.0f;
	public const float JumpVelocity = -400.0f;

	private Vector2 syncPos = new Vector2(0,0);
	private float syncRotation = 0;
	private AnimatedSprite2D _animatedSprite;

	// Get the gravity from the project settings to be synced with RigidBody nodes.
	public float gravity = ProjectSettings.GetSetting("physics/2d/default_gravity").AsSingle();

	public override void _Ready(){
		GetNode<MultiplayerSynchronizer>("MultiplayerSynchronizer").SetMultiplayerAuthority(int.Parse(Name));
		_animatedSprite = GetNode<AnimatedSprite2D>("AnimatedSprite");
	}
	public override void _PhysicsProcess(double delta)
	{
		if(GetNode<MultiplayerSynchronizer>("MultiplayerSynchronizer").GetMultiplayerAuthority() == Multiplayer.GetUniqueId())
		{
			Vector2 velocity = Velocity;

			// Add the gravity.
			if (!IsOnFloor())
				velocity.Y += gravity * (float)delta;

			// Handle Jump.
			if (Input.IsActionJustPressed("ui_accept") && IsOnFloor()) {
				velocity.Y = JumpVelocity;
			}
			if (!IsOnFloor())
				_animatedSprite.Play("jump");

			// Get the input direction and handle the movement/deceleration.
			// As good practice, you should replace UI actions with custom gameplay actions.
			Vector2 direction = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");
			if (direction != Vector2.Zero)
			{
				if (IsOnFloor())
					_animatedSprite.Play("move");
				velocity.X = direction.X * Speed;
			}
			else
			{
				velocity.X = Mathf.MoveToward(Velocity.X, 0, Speed);
			}
			if (velocity.X == 0 && IsOnFloor()) {
				_animatedSprite.Play("stand");
			}

			Velocity = velocity;
			MoveAndSlide();
			syncPos = GlobalPosition;
		}else{
			GlobalPosition = GlobalPosition.Lerp(syncPos, .1f);
		}
	}

	public void SetUpPlayer(string name){
		GetNode<Label>("Label").Text = name;
	}
}
