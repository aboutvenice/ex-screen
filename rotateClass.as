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
		public var angleX:Number=0; // 初始的环绕角度
		public var angleY:Number=0; // 初始的环绕角度		
		public var speed:Number=8; // 每帧环绕像素数
		public var distance:Number=800; // 轨道距原点的距离
		public var radX:Number; // 角度转换成弧度
		public var radY:Number;
		public var _x:Number=0
		public var _y:Number=0

		private var value_limitAngle:int=90
		private var value_rotateSpeed:Number=2
		//	
		public var myMatrix:Matrix3D=new Matrix3D()
		public var myVector:Vector3D=new Vector3D(0, 0, 0)
		public var centerMatrix:Matrix3D=new Matrix3D()
		public var centerVector:Vector3D=new Vector3D(0, 0, 0)
		//
		private var point_start:Number=500;

			
		
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
		
		public function start(valueX:Number,valueY:Number):void
		{		
				
			if(stage)
			{
				_x=valueX
				_y=valueY
				onRun()
				
			}else
			{
				trace("no stage!")
			}
			
			
		}
		
		
		protected function onRun():void
		{
			radX=angleX * (Math.PI / 180);
			radY=angleY * (Math.PI / 180);
			//
			obj_now.z=distance * Math.cos(radX); // 沿z轴定位盘旋物
			obj_now.x=distance * Math.sin(radX); // 沿x轴定位盘旋物
			obj_now.y=distance * Math.sin(radY); // 沿x轴定位盘旋物

			//
//			centerMatrix=obj_now.transform.matrix3D //拿到ball的位置
//			obj_center.x=centerMatrix.position.x + obj_now.width / 2 //移到中心點
//			obj_center.z=centerMatrix.position.z 
			//	
			myMatrix=obj_now.transform.matrix3D//拿到ball的位置
			myVector.x=myMatrix.position.x+(obj_now.width/2)  //將ball的x給vector3D
			myVector.y=myMatrix.position.y+(obj_now.height/2)
			myMatrix.appendTranslation(point_start, 0, 0)//將方塊移動畫面中心
			//	
			if ((_x < 0) && (angleX > (value_limitAngle*-1)))
			{//如果現在的x-之前的x是正數＝滑鼠向右移動
				
//				trace("減,往左")
				angleX-=speed; //对象顺时针圆周运动
				myMatrix.appendRotation((value_rotateSpeed*-1), Vector3D.Y_AXIS, myVector)//旋轉-2,Ｙ軸,旋轉中心點移到myVector的位置
				
			}
			else if ((_x > 0) && (angleX < value_limitAngle))
			{
//					trace("加,往右")
				angleX+=speed; //对象逆时针圆周运动
				myMatrix.appendRotation(value_rotateSpeed, Vector3D.Y_AXIS, myVector)
				
			}else if ((_y  > 0) && (angleY > value_limitAngle*-1))
			{//如果現在的x-之前的x是正數＝滑鼠向右移動
				
//				trace("減,往上")
				angleY-=speed; 
				obj_now.rotationX+=2	
				
			}
			else if ((_y < 0) && (angleY < value_limitAngle))
			{
				
//				trace("加,往下")
				angleY+=speed; 
				obj_now.rotationX-=2
				
			}
			else
			{
//				trace("不動")
			}
			
			obj_now.transform.matrix3D=myMatrix

			
			
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