package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;


	public class rotateClass extends MovieClip
	{
		public var obj_now:*

		//
		public var angleX:Number=0; // 初始的环绕角度
		public var angleY:Number=0; // 初始的环绕角度		
		public var speed:Number=8; // 每帧环绕像素数
		public var distance:Number=1500; // 轨道距原点的距离
		public var radX:Number; // 角度转换成弧度
		public var radY:Number;
		public var _x:Number=0
		public var _y:Number=0

		private var value_limitAngle:int=120
		//	
		//
		public var defaultYaw:Number
		public var defaultRoll:Number
		public var radius:Number
		public var ball:Sprite
		public var tag_run:Boolean=true



		public function rotateClass(obj:*, _yaw:Number, _roll:Number)
		{

			obj_now=obj //as DisplayObjectContainer
			defaultYaw=_yaw
			defaultRoll=_roll
			radius=Math.PI / 180

		}

		public function start(valueX:Number, valueY:Number):void
		{
			if (tag_run)
			{
				_x=valueX
				_y=valueY
				//	
				radX=angleX * radius
				radY=angleY * radius
				//
				obj_now.z=distance * Math.cos(radX); // 沿z轴定位盘旋物
				obj_now.x=distance * Math.sin(radX); // 沿x轴定位盘旋物
				obj_now.y=distance * Math.sin(radY); // 沿x轴定位盘旋物

				//	
				if ((_x < 0) && (_x > (value_limitAngle * -1)))
				{ //如果現在的x-之前的x是正數＝滑鼠向右移動

					//				trace("減,往左")
					angleX=_x
					obj_now.rotationY=angleX

				}
				else if ((_x > 0) && (_x < value_limitAngle))
				{
					//					trace("加,往右")
					angleX=_x
					obj_now.rotationY=angleX

				}

				if ((_y < 0) && (_y > (value_limitAngle * -1)))
				{

					//				trace("減,往上")
					angleY=_y * -1
					obj_now.rotationX=angleY * -1

				}
				else if ((_y > 0) && (_y < value_limitAngle))
				{

					//				trace("加,往下")
					angleY=_y * -1
					obj_now.rotationX=angleY * -1

				}
				else
				{
					//				trace("不動")
				}
			}


		}

		public function set setSpeed(value:Number):void
		{

			speed=value
		}

		public function set setDistance(value:Number):void
		{

			distance=value
		}

	}
}