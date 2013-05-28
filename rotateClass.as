package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	
	public class rotateClass extends Sprite
	{
		public var obj_now:Object
		public var obj_center:Object
		//
		public var angle:Number=0; // 初始的环绕角度
		public var speed:Number=8; // 每帧环绕像素数
		public var distance:Number=800; // 轨道距原点的距离
		public var rad:Number; // 角度转换成弧度
		private var value_limitAngle:int=90
		private var value_rotateSpeed:Number=2
		//	
		public var myMatrix:Matrix3D=new Matrix3D()
		public var myVector:Vector3D=new Vector3D(0, 0, 0)
		public var centerMatrix:Matrix3D=new Matrix3D()
		public var centerVector:Vector3D=new Vector3D(0, 0, 0)
		//
		private var point_start:Number=500;
		public var _x:Number=0

			
		
		public function rotateClass(obj:Object,cent:Object) 
		{
			
			obj_now=obj
			obj_center=cent
			//
			
			if(stage)
			{ 
				init()  
			}else
			{
				addEventListener(Event.ADDED_TO_STAGE,init);
			}
			
		}
		
		public function init(e:Event=null):void{
			
		}
		
		public function start(value:Number):void
		{		
				
			if(stage)
			{
				_x=value
				onRun()
				
			}else
			{
				trace("no stage!")
			}
			
		}
		
		
		protected function onRun():void
		{
			rad=angle * (Math.PI / 180);
			//
			obj_now.z=distance * Math.cos(rad); // 沿z轴定位盘旋物
			obj_now.x=distance * Math.sin(rad); // 沿x轴定位盘旋物
			//
			centerMatrix=obj_now.transform.matrix3D //拿到ball的位置
			obj_center.x=centerMatrix.position.x + obj_now.width / 2 //移到中心點
			obj_center.z=centerMatrix.position.z 
			//	
			myMatrix=obj_now.transform.matrix3D//拿到ball的位置
			myVector.x=myMatrix.position.x//將ball的x給vector3D
			myMatrix.appendTranslation(point_start, 0, 0)//將方塊移動畫面中心
			//	
			if ((_x < 0) && (angle > (value_limitAngle*-1)))
			{//如果現在的x-之前的x是正數＝滑鼠向右移動
				
				//trace("減,往左")
				//ball.rotationY-=speed
				angle-=speed; //对象顺时针圆周运动
				myMatrix.appendRotation((value_rotateSpeed*-1), Vector3D.Y_AXIS, myVector)//旋轉-2,Ｙ軸,旋轉中心點移到myVector的位置
				
			}
			else if ((_x > 0) && (angle < value_limitAngle))
			{
				//	trace("加,往右")
				//ball.rotationY+=speed
				angle+=speed; //对象逆时针圆周运动
				myMatrix.appendRotation(value_rotateSpeed, Vector3D.Y_AXIS, myVector)
				
			}
			else
			{
				//trace("不動")
			}
			
			
		}
		
		public function set setSpeed (value:Number) :void
		{
			
			speed=value
		}
		
		public function set setDistance (value:Number) :void
		{
			
			distance=value
		}
		
		public function set setPointStart(value:Number):void 
		{
		
			point_start=value
		}
		
		public function set setRotateSpeed(value:Number):void 
		{
			value_rotateSpeed=value
		}
	}
}