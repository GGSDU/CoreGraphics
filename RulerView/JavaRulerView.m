//
//  RulerView.m
//  OpenCVDetectCircleDemo
//
//  Created by Story5 on 3/27/17.
//  Copyright © 2017 Story5. All rights reserved.
//

#import "JavaRulerView.h"
#import "JavaRulerCalculator.h"

static int LINE_TYPE_DASH_LINE = 1;
static int LINE_TYPE_LINE = 2;
static int INVALID_POINTER_ID = -1;

static int MEASURE_BTN_START_X = 50;//dp
static int MEASURE_BTN_START_Y = 80;//dp
static int MEASURE_BTN_BOTTOM_START_Y = 200;//dp
static int DASH_LINE_BLANK_DEFAULT = 3;//dp
static int MEASURE_TEXT_SIZE_DEFAULT = 18;//sp
static int RULER_WIDTH = 30;
static int RULER_SCALE_WIDTH = 3;
static int MEASURE_ICON_SIZE = 30;

static int _scale = 0;

@implementation TouchPoint

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pointerId = INVALID_POINTER_ID;
    }
    return self;
}

@end

@interface JavaRulerView ()

@property(nonatomic,strong) JavaRulerCalculator *rulerCalculator;


@property(nonatomic,strong) NSThread *drawThread;

@property(nonatomic,assign) float lineHeight;
@property(nonatomic,assign) float rulerLineHeight;
@property(nonatomic,assign) float dashLineBlank;
@property(nonatomic,assign) float measureTextSizef;

@property(nonatomic,assign) float rulerWidth;
@property(nonatomic,assign) float rulerScaleWidth;
@property(nonatomic,assign) float measureIconSize;

@property(nonatomic,assign) float finalMeasureLength;

@property(nonatomic,assign) double detectScale;

@property(nonatomic,assign) CGPoint measureBtn1Pos;
@property(nonatomic,assign) CGPoint measureBtn2Pos;
@property(nonatomic,assign) CGRect measureTextSize;

@property(nonatomic,assign) BOOL isMeasureBtn1CanMove;
@property(nonatomic,assign) BOOL isMeasureBtn2CanMove;

@property(nonatomic,assign) BOOL applyCameraScale;

@property(nonatomic,assign) BOOL drawFlag;

@property(nonatomic,assign) BOOL showBorder;
@property(nonatomic,assign) BOOL lastBorderVisible;


@property(nonatomic,assign) int lineType;

@property(nonatomic,assign) float realBitmapScale;
@property(nonatomic,strong) UIColor *lineColor;
@property(nonatomic,strong) UIColor *rulerColor;
@property(nonatomic,strong) UIColor *measureTextColor;


//@property(nonatomic,assign) Paint linePaint = new Paint(Paint.ANTI_ALIAS_FLAG);

@property(nonatomic,assign) CGContextRef context;
//@property(nonatomic,assign) OnMeasureBtnListener onMeasureBtnListener;
//@property(nonatomic,assign) Paint rulerPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
//@property(nonatomic,assign) Paint textPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
//@property(nonatomic,assign) TouchPoint[] tpoints = new TouchPoint[2];
//@property(nonatomic,assign) SurfaceHolder surfaceHolder;

@end

@implementation JavaRulerView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.drawFlag = true;
        self.showBorder = true;
        self.lastBorderVisible = true;
        self.lineType = LINE_TYPE_DASH_LINE;
        
        self.realBitmapScale = 1;
        self.lineColor = [UIColor whiteColor];
        self.rulerColor = [UIColor whiteColor];
        self.measureTextColor = [UIColor whiteColor];
    }
    return self;
}


- (double)distance:(CGPoint)btn1 btn2:(CGPoint)btn2
{
    return sqrt(pow(btn1.x - btn2.x, 2) + pow(btn1.y - btn2.y, 2));
}

- (double)rulerLength
{
    //        DisplayMetrics dm = new DisplayMetrics();
    //        dm = context.getResources().getDisplayMetrics();
    //        int screenWidth = dm.widthPixels;
    //        int screenHeight = dm.heightPixels;
    //        double width=screenWidth*25.4/ distance(measureBtn1Pos, measureBtn2Pos);
    return  [self distance:self.measureBtn1Pos btn2:self.measureBtn2Pos];
}

- (void)drawRuler:(CGContextRef)canvas
{
    if (self.rulerCalculator != nil) {
        
        [self.rulerCalculator calculate:self.measureBtn1Pos btn2:self.measureBtn2Pos];
        //画标尺
        NSArray *points = self.rulerCalculator.rulerLinePoints;
        if (points != nil && points.count == 4) {
            
            CGPoint point0 = [points[0] CGPointValue];
            CGPoint point1 = [points[1] CGPointValue];
            CGPoint point2 = [points[2] CGPointValue];
            CGPoint point3 = [points[3] CGPointValue];
            
            CGMutablePathRef pathRuler1 = CGPathCreateMutable();
            CGPathMoveToPoint(pathRuler1, nil, point0.x, point0.y);
            CGPathAddLineToPoint(pathRuler1, nil, point1.x, point1.y);
            CGContextAddPath(canvas, pathRuler1);
            CGContextDrawPath(canvas, kCGPathStroke);
            
            NSString *text = [NSString stringWithFormat:@"长度为：%fmm",(double)round([self rulerLength] * _scale * 100) / 100];
            NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:30],
                                        NSForegroundColorAttributeName:[UIColor colorWithRed:44 / 255.0 green:159 / 255.0 blue:229 / 255.0 alpha:1]};
            //获取屏幕信息
            //                Display d = ((Activity) context).getWindowManager().getDefaultDisplay();
            //                int screenWidth = dm.widthPixels;
            //                int screenHeigh = dm.heightPixels;
            [text drawAtPoint:point0 withAttributes:attribute];
            
            CGMutablePathRef pathRuler2 = CGPathCreateMutable();
            CGPathMoveToPoint(pathRuler2, nil, point2.x, point2.y);
            CGPathAddLineToPoint(pathRuler2, nil, point3.x, point3.y);
            CGContextAddPath(canvas, pathRuler2);
            CGContextDrawPath(canvas, kCGPathStroke);
        }
        
        //画尺子边框
        NSArray *rulerPoints = self.rulerCalculator.rulerPoints;
        if (rulerPoints != nil && rulerPoints.count == 4) {
            CGPoint point0 = [rulerPoints[0] CGPointValue];
            CGPoint point1 = [rulerPoints[1] CGPointValue];
            CGPoint point2 = [rulerPoints[2] CGPointValue];
            CGPoint point3 = [rulerPoints[3] CGPointValue];
            
            
            CGMutablePathRef pathRuler1 = CGPathCreateMutable();
            CGPathMoveToPoint(pathRuler1, nil, point0.x, point0.y);
            CGPathAddLineToPoint(pathRuler1, nil, point2.x, point2.y);
            CGContextAddPath(canvas, pathRuler1);
            CGContextDrawPath(canvas, kCGPathStroke);
            
            CGMutablePathRef pathRuler2 = CGPathCreateMutable();
            CGPathMoveToPoint(pathRuler2, nil, point1.x, point1.y);
            CGPathAddLineToPoint(pathRuler2, nil, point3.x, point3.y);
            CGContextAddPath(canvas, pathRuler2);
            CGContextDrawPath(canvas, kCGPathStroke);
            
            CGMutablePathRef pathRuler3 = CGPathCreateMutable();
            CGPathMoveToPoint(pathRuler3, nil, point0.x, point0.y);
            CGPathAddLineToPoint(pathRuler3, nil, point1.x, point1.y);
            CGContextAddPath(canvas, pathRuler3);
            CGContextDrawPath(canvas, kCGPathStroke);
            
            CGMutablePathRef pathRuler4 = CGPathCreateMutable();
            CGPathMoveToPoint(pathRuler4, nil, point2.x, point2.y);
            CGPathAddLineToPoint(pathRuler4, nil, point3.x, point3.y);
            CGContextAddPath(canvas, pathRuler4);
            CGContextDrawPath(canvas, kCGPathStroke);
        }
        
        //画尺子刻度
        NSArray *bottomScalePoints = self.rulerCalculator.rulerBottomScalePoints;
        NSArray *top1ScalePoints = self.rulerCalculator.rulerTop1ScalePoints;
        NSArray *top2ScalePoints = self.rulerCalculator.rulerTop2ScalePoints;
        NSArray *operatorPoints = self.rulerCalculator.operatorPoints;
        //画尺子小刻度
        if (bottomScalePoints != nil && bottomScalePoints.count > 0
            && top1ScalePoints != nil && top1ScalePoints.count > 0) {
            for (int i = 0; i < bottomScalePoints.count; i++) {
                CGPoint top1Pointi = [top1ScalePoints[i] CGPointValue];
                CGPoint bottomPointi = [bottomScalePoints[i] CGPointValue];


                CGMutablePathRef path = CGPathCreateMutable();
                CGPathMoveToPoint(path, nil, top1Pointi.x, top1Pointi.y);
                CGPathAddLineToPoint(path, nil, bottomPointi.x, bottomPointi.y);
                CGContextAddPath(canvas, path);
                CGContextDrawPath(canvas, kCGPathStroke);
            }
        }
        //画尺子大刻度
        if (bottomScalePoints != nil && bottomScalePoints.count > 0
            && top2ScalePoints != nil && top2ScalePoints.count > 0) {
            for (int i = 0; i < top2ScalePoints.count; i++) {
                int index = (i + 1) * 5 - 1;
                if (bottomScalePoints.count > index) {
                    CGPoint top2Pointi = [top2ScalePoints[i] CGPointValue];
                    CGPoint bottomPointi = [bottomScalePoints[(i + 1) * 5 -1] CGPointValue];
                    
                    CGMutablePathRef path = CGPathCreateMutable();
                    CGPathMoveToPoint(path, nil, top2Pointi.x, top2Pointi.y);
                    CGPathAddLineToPoint(path, nil, bottomPointi.x, bottomPointi.y);
                    CGContextAddPath(canvas, path);
                    CGContextDrawPath(canvas, kCGPathStroke);
                }
            }
        }
        
        //画操作按钮
        if (operatorPoints != nil && operatorPoints.count == 4) {
            CGPoint point0 = [operatorPoints[0] CGPointValue];
            CGPoint point1 = [operatorPoints[1] CGPointValue];
            CGPoint point2 = [operatorPoints[2] CGPointValue];
            CGPoint point3 = [operatorPoints[3] CGPointValue];

            
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, nil, self.measureBtn1Pos.x, self.measureBtn1Pos.y);
            CGPathAddLineToPoint(path, nil, point0.x, point0.y);
            CGContextAddPath(canvas, path);
            CGContextDrawPath(canvas, kCGPathStroke);
            
            CGPathMoveToPoint(path, nil, point0.x, point0.y);
            CGPathAddLineToPoint(path, nil, point1.x, point1.y);
            CGContextAddPath(canvas, path);
            CGContextDrawPath(canvas, kCGPathStroke);
            
            CGPathMoveToPoint(path, nil, point1.x, point1.y);
            CGPathAddLineToPoint(path, nil, self.measureBtn1Pos.x, self.measureBtn1Pos.y);
            CGContextAddPath(canvas, path);
            CGContextDrawPath(canvas, kCGPathStroke);
            
            
            CGPathMoveToPoint(path, nil, self.measureBtn2Pos.x, self.measureBtn2Pos.y);
            CGPathAddLineToPoint(path, nil, point2.x, point2.y);
            CGContextAddPath(canvas, path);
            CGContextDrawPath(canvas, kCGPathStroke);
            
            CGPathMoveToPoint(path, nil, point2.x, point2.y);
            CGPathAddLineToPoint(path, nil, point3.x, point3.y);
            CGContextAddPath(canvas, path);
            CGContextDrawPath(canvas, kCGPathStroke);
            
            CGPathMoveToPoint(path, nil, point3.x, point3.y);
            CGPathAddLineToPoint(path, nil, self.measureBtn2Pos.x, self.measureBtn2Pos.y);
            CGContextAddPath(canvas, path);
            CGContextDrawPath(canvas, kCGPathStroke);
        }
    }
}

#pragma mark - unchange java code
//public void setOnMeasureBtnListener(OnMeasureBtnListener onMeasureBtnListener) {
//    this.onMeasureBtnListener = onMeasureBtnListener;
//}
//
//public RulerSurfaceView(Context context, AttributeSet attrs, int defStyleAttr) {
//    super(context, attrs, defStyleAttr);
//    TypedArray typedArray = getContext().obtainStyledAttributes(attrs,
//                                                                R.styleable.RulerSurfaceView    , defStyleAttr, 0);
//    init(typedArray);
//}
//
//private void init(TypedArray typedArray) {
//    setZOrderOnTop(true);
//    surfaceHolder = getHolder();
//    surfaceHolder.setFormat(PixelFormat.TRANSLUCENT);
//    surfaceHolder.addCallback(this);
//    drawThread = new Thread(this);
//    
//    lineHeight = typedArray.getDimension(R.styleable.RulerSurfaceView_line_height,
//                                         dp2px(getContext(), 1));
//    rulerLineHeight = typedArray.getDimension(R.styleable.RulerSurfaceView_ruler_line_height,
//                                              dp2px(getContext(), 2));
//    lineType = typedArray.getInt(R.styleable.RulerSurfaceView_line_type, LINE_TYPE_DASH_LINE);
//    lineColor = typedArray.getColor(R.styleable.RulerSurfaceView_line_color, Color.WHITE);
//    rulerColor = typedArray.getColor(R.styleable.RulerSurfaceView_ruler_color, Color.WHITE);
//    dashLineBlank = typedArray.getDimension(R.styleable.RulerSurfaceView_dash_line_blank,
//                                            dp2px(getContext(), DASH_LINE_BLANK_DEFAULT));
//    rulerWidth = typedArray.getDimension(
//                                         R.styleable.RulerSurfaceView_measure_ruler_width,
//                                         dp2px(getContext(), RULER_WIDTH));
//    rulerScaleWidth = typedArray.getDimension(
//                                              R.styleable.RulerSurfaceView_measure_ruler_scale_width,
//                                              dp2px(getContext(), RULER_SCALE_WIDTH));
//    measureIconSize = typedArray.getDimension(
//                                              R.styleable.RulerSurfaceView_measure_icon_size,
//                                              dp2px(getContext(), MEASURE_ICON_SIZE));
//    
//    initMeasureBtnRect();
//}
//
//private void initMeasureBtnRect() {
//    int width = getWidth();
//    if (width > 0) {
//        float left = width - dp2px(getContext(), MEASURE_BTN_START_X);
//        float top = dp2px(getContext(), MEASURE_BTN_START_Y);
//        measureBtn1Pos.x = (int) left;
//        measureBtn1Pos.y = (int) top;
//        
//        measureBtn2Pos.x = (int) left;
//        measureBtn2Pos.y = getHeight() - MEASURE_BTN_BOTTOM_START_Y * 2;
//        
//        invalidate();
//        rulerCalculator = new RulerCalculator(getWidth(), getHeight(),
//                                              rulerWidth, rulerScaleWidth, measureIconSize);
//    }
//}
//
//@Override
//protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
//    super.onLayout(changed, left, top, right, bottom);
//    initMeasureBtnRect();
//}
//
//@Override
//public void surfaceCreated(SurfaceHolder holder) {
//    setDrawFlag(true);
//    drawThread = new Thread(this);
//    drawThread.start();
//}
//
//@Override
//public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
//    
//}
//
//@Override
//public void surfaceDestroyed(SurfaceHolder holder) {
//    setDrawFlag(false);
//    drawThread = nil;
//}
//
//@Override
//public boolean onTouchEvent(MotionEvent event) {
//    int pointerCount = MotionEventCompat.getPointerCount(event);
//    final int action = MotionEventCompat.getActionMasked(event);
//    switch (action) {
//        case MotionEvent.ACTION_DOWN: {
//            if (pointerCount > 2) {
//                break;
//            }
//            int pointerIndex = MotionEventCompat.getActionIndex(event);
//            int activePointerId = MotionEventCompat.getPointerId(event, pointerIndex);
//            TouchPoint tpoint = getTouchPoint(activePointerId);
//            if (tpoint != nil) {
//                float x = MotionEventCompat.getX(event, activePointerId);
//                float y = MotionEventCompat.getY(event, activePointerId);
//                tpoint.x = x;
//                tpoint.y = y;
//                tpoint.pointerId = activePointerId;
//                
//                showBorder = checkBtnCanMove(tpoints);
//                if (onMeasureBtnListener != nil) {
//                    if (!showBorder) {
//                        lastBorderVisible = onMeasureBtnListener.onShowBorder(showBorder);
//                    }
//                }
//            }
//            break;
//        }
//        case MotionEvent.ACTION_MOVE: {
//            if (pointerCount > 2) {
//                break;
//            }
//            moveMeasureBtn(tpoints, event);
//            invalidate();
//            break;
//        }
//        case MotionEvent.ACTION_UP: {
//            if (onMeasureBtnListener != nil) {
//                if (lastBorderVisible && showBorder) {
//                    showBorder = false;
//                }
//                lastBorderVisible = onMeasureBtnListener.onShowBorder(showBorder);
//            }
//            
//            isMeasureBtn1CanMove = false;
//            isMeasureBtn2CanMove = false;
//            
//            for (TouchPoint tp : tpoints) {
//                if (tp != nil) {
//                    tp.pointerId = INVALID_POINTER_ID;
//                    tp.inArea = nil;
//                }
//            }
//            break;
//        }
//        case MotionEvent.ACTION_POINTER_DOWN: {
//            if (pointerCount > 2) {
//                break;
//            }
//            int pointerIndex = MotionEventCompat.getActionIndex(event);
//            int activePointerId = MotionEventCompat.getPointerId(event, pointerIndex);
//            TouchPoint tpoint = getTouchPoint(activePointerId);
//            if (tpoint != nil) {
//                float x = MotionEventCompat.getX(event, activePointerId);
//                float y = MotionEventCompat.getY(event, activePointerId);
//                tpoint.x = x;
//                tpoint.y = y;
//                tpoint.pointerId = activePointerId;
//                
//                showBorder = checkBtnCanMove(tpoints);
//                if (onMeasureBtnListener != nil) {
//                    if (!showBorder) {
//                        lastBorderVisible = onMeasureBtnListener.onShowBorder(showBorder);
//                    }
//                }
//            }
//            break;
//        }
//        case MotionEvent.ACTION_POINTER_UP: {
//            if (onMeasureBtnListener != nil) {
//                if (lastBorderVisible && showBorder) {
//                    showBorder = false;
//                }
//                lastBorderVisible = onMeasureBtnListener.onShowBorder(showBorder);
//            }
//            
//            int pointerIndex = MotionEventCompat.getActionIndex(event);
//            for (TouchPoint tp : tpoints) {
//                if (tp != nil && tp.pointerId == pointerIndex) {
//                    tp.pointerId = INVALID_POINTER_ID;
//                }
//            }
//            break;
//        }
//    }
//    return true;
//}
//
//@Override
//public void run() {
//    while (drawFlag) {
//        Canvas canvas = nil;
//        synchronized (surfaceHolder) {
//            try {
//                canvas = surfaceHolder.lockCanvas();
//                canvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR);
//                innerDraw(canvas);
//            } catch (Exception e) {
//                e.printStackTrace();
//            } finally {
//                if (nil != canvas) {
//                    surfaceHolder.unlockCanvasAndPost(canvas);
//                }
//            }
//        }
//    }
//}
//
//private TouchPoint getTouchPoint(int pointerId) {
//    for (TouchPoint tp : tpoints) {
//        if (tp != nil && tp.pointerId == pointerId) {
//            return tp;
//        }
//    }
//    
//    for (TouchPoint tp : tpoints) {
//        if (tp != nil && tp.pointerId == INVALID_POINTER_ID) {
//            tp.pointerId = pointerId;
//            return tp;
//        }
//    }
//    
//    for (int i = 0; i < tpoints.length; i++) {
//        if (tpoints[i] == nil) {
//            tpoints[i] = new TouchPoint();
//            tpoints[i].pointerId = pointerId;
//            return tpoints[i];
//        }
//    }
//    
//    return nil;
//}
//
//private void moveMeasureBtn(TouchPoint[] tpts, MotionEvent event) {
//    List<TouchPoint> movePts = new ArrayList<>();
//    for (TouchPoint tpt1 : tpts) {
//        if (tpt1 != nil && tpt1.pointerId != INVALID_POINTER_ID) {
//            int pointerIndex = MotionEventCompat.findPointerIndex(event, tpt1.pointerId);
//            float x = MotionEventCompat.getX(event, pointerIndex);
//            float y = MotionEventCompat.getY(event, pointerIndex);
//            TouchPoint movePt = new TouchPoint();
//            movePt.x = x;
//            movePt.y = y;
//            movePt.pointerId = pointerIndex;
//            movePts.add(movePt);
//        }
//    }
//    for (TouchPoint tpt : tpts) {
//        for (TouchPoint movePt : movePts) {
//            if (tpt != nil && tpt.pointerId != INVALID_POINTER_ID
//                && movePt != nil && movePt.pointerId == tpt.pointerId) {
//                float y = movePt.y;
//                float x = movePt.x;
//                if (tpt.inArea == measureBtn1Pos) {
//                    int top = (int) (y - measureIconSize);
//                    int left = (int) (x - measureIconSize);
//                    int width = (int) measureIconSize;
//                    int deltaX = tpt.deltaPoint.x;
//                    int deltaY = tpt.deltaPoint.y;
//                    
//                    if (top <= 0) {
//                        top = 0;
//                    }
//                    
//                    if (top >= getHeight() - measureIconSize -
//                        Tools.getNavigationBarHeight(getContext())) {
//                        top = (int) (getHeight() - measureIconSize -
//                                     Tools.getNavigationBarHeight(getContext()));
//                    }
//                    
//                    if (left < 0) {
//                        left = 0;
//                    }
//                    
//                    if (left + width > getWidth()) {
//                        left = getWidth() - width;
//                    }
//                    
//                    measureBtn1Pos.y = (int) (top + measureIconSize - deltaY);
//                    measureBtn1Pos.x = (int) (left + measureIconSize - deltaX);
//                    
//                    if (onMeasureBtnListener != nil) {
//                        onMeasureBtnListener.onMove();
//                    }
//                }
//                
//                if (tpt.inArea == measureBtn2Pos) {
//                    int top = (int) (y - measureIconSize);
//                    int left = (int) (x - measureIconSize);
//                    int width = (int) measureIconSize;
//                    int deltaX = tpt.deltaPoint.x;
//                    int deltaY = tpt.deltaPoint.y;
//                    
//                    if (top <= 0) {
//                        top = 0;
//                    }
//                    
//                    if (top >= getHeight() - measureIconSize -
//                        Tools.getNavigationBarHeight(getContext())) {
//                        top = (int) (getHeight() - measureIconSize -
//                                     Tools.getNavigationBarHeight(getContext()));
//                    }
//                    
//                    if (left < 0) {
//                        left = 0;
//                    }
//                    
//                    if (left + width > getWidth()) {
//                        left = getWidth() - width;
//                    }
//                    
//                    measureBtn2Pos.y = (int) (top + measureIconSize - deltaY);
//                    measureBtn2Pos.x = (int) (left + measureIconSize - deltaX);
//                    
//                    if (onMeasureBtnListener != nil) {
//                        onMeasureBtnListener.onMove();
//                    }
//                }
//            }
//        }
//    }
//}
//
//private boolean checkBtnCanMove(TouchPoint[] tpts) {
//    //        int touchArea = Tools.dp2px(getContext(), 20);
//    int checkArea = (int) (measureIconSize * 2);
//    for (TouchPoint tpt : tpts) {
//        if (tpt != nil && tpt.pointerId != INVALID_POINTER_ID) {
//            if (tpt.x > measureBtn1Pos.x - checkArea &&
//                tpt.x < measureBtn1Pos.x + checkArea &&
//                tpt.y > measureBtn1Pos.y - checkArea &&
//                tpt.y < measureBtn1Pos.y + checkArea) {
//                isMeasureBtn1CanMove = true;
//                if (tpt.inArea == nil) {
//                    tpt.deltaPoint.x = (int) (tpt.x - measureBtn1Pos.x);
//                    tpt.deltaPoint.y = (int) (tpt.y - measureBtn1Pos.y);
//                }
//                tpt.inArea = measureBtn1Pos;
//            }
//            
//            if (tpt.x > measureBtn2Pos.x - checkArea &&
//                tpt.x < measureBtn2Pos.x + checkArea &&
//                tpt.y > measureBtn2Pos.y - checkArea &&
//                tpt.y < measureBtn2Pos.y + checkArea) {
//                isMeasureBtn2CanMove = true;
//                if (tpt.inArea == nil) {
//                    tpt.deltaPoint.x = (int) (tpt.x - measureBtn2Pos.x);
//                    tpt.deltaPoint.y = (int) (tpt.y - measureBtn2Pos.y);
//                }
//                tpt.inArea = measureBtn2Pos;
//            }
//        }
//    }
//    
//    return !(isMeasureBtn1CanMove | isMeasureBtn2CanMove);
//}
//
//private void initPaint() {
//    linePaint.setColor(lineColor);
//    linePaint.setStrokeWidth(lineHeight);
//    linePaint.setStyle(Paint.Style.STROKE);
//    if (lineType == LINE_TYPE_DASH_LINE) {
//        PathEffect effects = new DashPathEffect(new float[]{dashLineBlank, dashLineBlank,
//            dashLineBlank, dashLineBlank}, 1);
//        linePaint.setPathEffect(effects);
//    }
//    
//    rulerPaint.setColor(rulerColor);
//    rulerPaint.setStrokeWidth(rulerLineHeight);
//    rulerPaint.setStyle(Paint.Style.STROKE);
//}
//
//private void innerDraw(Canvas canvas) {
//    initPaint();
//    
//    drawRuler(canvas);
//    //        float length = (float) rulerLength();
//    //        drawMeasureText(canvas, length, (float) detectScale);
//}
//
//
//String Scale;
//public void setScale(String txt){
//    Scale=txt;
//}
//
//
//String width=nil;
//public String setWidth(int X){
//    width=X+"";
//    return width;
//}
//
//public interface OnMeasureBtnListener {
//    boolean onShowBorder(boolean visible);
//    
//    void onMove();
//}
//
//
//
//public static int dp2px(Context context, int dp) {
//    final float scale = context.getResources().getDisplayMetrics().density;
//    return (int) (dp * scale + 0.5f);
//}

@end
