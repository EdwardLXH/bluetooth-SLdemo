//
//  ViewController.h
//  smart-Light
//
//  Created by edward on 27/11/17.
//  Copyright © 2017年 Edward. All rights reserved.
//


#import "ViewController.h"
#import "UIView+frame.h"
#import "GlobalPublicDefine.h"
#import "UITableViewCell+Help.h"
#import "DeviceNameCell.h"

#import <CoreBluetooth/CoreBluetooth.h>

#define tableWMargin  SLWidth*0.5-125
#define tableHMargin  SLHeight*0.5-170

#define eDeviceNameKey @"peripheral"
#define SLDeviceConnectState  @"SLDeviceConnectState"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource,CBPeripheralDelegate,CBCentralManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *deviceNameTF;


@property (weak, nonatomic) IBOutlet UITextField *deviceConnectTF;

@property (weak, nonatomic) IBOutlet UIButton *addDeviceBtn;

@property (weak, nonatomic) IBOutlet UISlider *lightBrightness;


@property (weak, nonatomic) IBOutlet UILabel *LBcount;


/** uitableView  */
@property (nonatomic,strong) UITableView *tableView;

/** device arr  */
@property (nonatomic,strong) NSMutableArray *deviceArr;


/** central */
@property (nonatomic,strong) CBCentralManager *centralManager;

/** Current peripheral  */
@property (nonatomic,strong) CBPeripheral *currentPeripheral;

/**   */
@property (nonatomic,strong) dispatch_queue_t tableVqueue;

/** juhua  */
@property (nonatomic,strong)  UIActivityIndicatorView *juhua;


/** P connect state  */
@property (nonatomic,assign) BOOL isSLDeviceConnected;
@end



@implementation ViewController

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
    }
    return _tableView;
}

-(CBCentralManager *)centralManager
{
    if (!_centralManager) {
        //bluetooth 队列名字,   DISPATCH_QUEUE_SERIAL 串行队列, 要深入了解, 百度,谷歌走起哈...学到都是自己的嘛.
        dispatch_queue_t myqueue = dispatch_queue_create("bluetooth", DISPATCH_QUEUE_SERIAL);
        
        //CBCentralManagerOptionShowPowerAlertKey  启动App的时候给用户提示, 需要开启蓝牙功能. 类似要使用蜂窝网一个意思.
        _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:myqueue options:@{CBCentralManagerOptionShowPowerAlertKey : @NO }];
    }
    return _centralManager;
}


-(NSMutableArray *)deviceArr
{
    if (!_deviceArr) {
        _deviceArr = [NSMutableArray array];
    }
    
    return _deviceArr;
}


-(dispatch_queue_t)tableVqueue
{
    if (!_tableVqueue) {
        _tableVqueue = dispatch_queue_create("com.tableVqueue", DISPATCH_QUEUE_SERIAL);
    }
    return _tableVqueue;
}


-(UIActivityIndicatorView *)juhua
{
    if (!_juhua) {
        _juhua = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        _juhua.center = CGPointMake(((SLWidth*0.5)+125.0)*0.5, ((SLHeight*0.5)+280.0)*0.90);
        _juhua.center = CGPointMake(((tableWMargin)+250)*0.5,((tableHMargin)+450)*0.90);

        _juhua.backgroundColor = [UIColor whiteColor];
        _juhua.alpha = 0.8;
        [self.view addSubview:_juhua];
    }
    return _juhua;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configSlider];
    
    //调用一下 手机蓝牙的 状态,  这个方法 centralManagerDidUpdateState: 各种状态都有.
    //这里调用时因为 我在 power off 做了 [self powerOff] 处理,   可以自行做处理.
    [self.centralManager state];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sld_changeConnect:) name:SLDeviceConnectState object:nil];
}
#pragma mark Notification  📩
#pragma mark -----------------------------------
-(void)sld_changeConnect:(NSNotification *)notification
{
    BOOL temp = [[notification.userInfo objectForKey:@"state"] boolValue];
    
    self.isSLDeviceConnected = temp;
    
}


#pragma mark init  ⚙
#pragma mark -----------------------------------
-(void)configSlider
{
    _lightBrightness.minimumValue = 0.0; _lightBrightness.maximumValue = 100.0;
    _lightBrightness.value = 0.0;       _lightBrightness.continuous = YES;
    
    [_lightBrightness addTarget:self action:@selector(lightBrightnessDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    
    
    //add button
//    [_addDeviceBtn setTitle:@"Add device" forState:UIControlStateNormal];
//    [_addDeviceBtn setTitle:@"Remove device" forState:UIControlStateSelected];
    
}

-(void)configTableView
{
    self.tableView.frame = CGRectMake(SLWidth*0.5-125, SLHeight*0.5-170, 250, 450);
    self.tableView.delegate = self;  self.tableView.dataSource = self;
    [self.tableView registerNib:[DeviceNameCell nib] forCellReuseIdentifier:NSStringFromClass([DeviceNameCell class])];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.layer.borderColor = [UIColor blackColor].CGColor;
    self.tableView.layer.borderWidth = 1;
//    self.tableView.tableHeaderView = [UIView new];
//    self.tableView.backgroundColor = [UIColor orangeColor];
    [self.view insertSubview:self.tableView atIndex:1];
    
}



#pragma mark function 🔧
#pragma mark -------------------------------------------
-(void)lightBrightnessDidChangeValue:(UISlider *)slider
{
    NSLog(@"value ====== %f",slider.value);
    self.LBcount.text = [NSString stringWithFormat:@"%.1f%%",slider.value];
    
    //写入 到 连接的 设备.......
    //这里需要注意的是, 这个 Data 可能需要 做一些处理, 这个 是要和 硬件的交互命令 匹配好的.
//    [self.currentPeripheral writeValue:[NSData data] forCharacteristic:self.currentPeripheral.services.lastObject.characteristics.lastObject type:CBCharacteristicWriteWithResponse];

}
- (IBAction)didAddDevice:(UIButton *)sender
{
    
    if ([self.centralManager state] == CBCentralManagerStatePoweredOff) {
        
        [self showToTurnOnBluetooth];
        return;
    }
    
    //选中 remove device
    if (sender.selected) {
        
        self.deviceNameTF.text = @"NULL";
        self.deviceConnectTF.text = @"NULL";
        //断开之前的 peripheral
        [self.centralManager cancelPeripheralConnection:self.currentPeripheral];
        sender.selected = NO;
//        self.isSLDeviceConnected = NO;

        //stop juhua loading
//        [self.juhua stopAnimating];

    }else
    {

        [self.centralManager stopScan];
        [self.tableView removeFromSuperview];
        self.tableView = nil;
        [self.deviceArr removeAllObjects];
        
        [self configTableView];
        
        self.isSLDeviceConnected = NO;
        
        
        
        //搜索 制定 peripheral 设备
        
        //Service UUID 是 设备的 唯一标识, 用来连接指定外设时使用
        //Characteristic UUID 这个是用来订阅,读取,写入 特征时使用的.具体使用看   CBPeripheralDelegate方法
        //[self.centralManager scanForPeripheralsWithServices:@[@"Service UUID"] options:@{CBCentralManagerScanOptionSolicitedServiceUUIDsKey : @[@[@"Service UUID"]] }];
        
        
        //搜索 所有 peripheral 设备
        //CBCentralManagerScanOptionAllowDuplicatesKey 这个时 重复扫描, 就是没完没了的扫描 外设. 一半为 NO.
        //[self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        
        //juhua  loading..
        EqueueAsyncMainStart(dispatch_get_main_queue())
        [self.juhua startAnimating];
        EqueueEnd
    }
}



-(void)showToTurnOnBluetooth
{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"tips" message:@"turn on Bluetooth" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      
//        NSURL * url = [NSURL URLWithString：@“prefs：root = LOCATION_SERVICES”];

        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.000000) {
            //  (@available(iOS 10.0, *))  和上面的判断  >=10.00 是一个意思, 只不过这个是在Xcode9后有的语法
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root=Bluetooth"] options:@{} completionHandler:^(BOOL success) {
                    
                    NSLog(@"打开蓝牙成功了");
                }];
            } else {
                // Fallback on earlier versions
                
            }

        }else{
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }];
    
    [alertVc addAction:action1];
    [alertVc addAction:action2];
    
    [self presentViewController:alertVc animated:NO completion:^{
    }];
    
}

-(void)powerOff
{
    EqueueSyncMainStart(dispatch_get_main_queue())
    [self.tableView removeFromSuperview];
    self.tableView = nil;
    [self.deviceArr removeAllObjects];
    [self showToTurnOnBluetooth];
    [self.juhua stopAnimating];
    EqueueEnd
}
#pragma mark CBCentralManagerDelegate 🎥
#pragma mark -------------------------------------------
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            SCLog(@"power on............................")
            break;
        case CBCentralManagerStatePoweredOff:
            SCLog(@"power off............................")
        
            [self powerOff];
            break;

        case CBCentralManagerStateUnknown:
            SCLog(@"Unknown............................")
            break;
        case CBCentralManagerStateResetting:
            SCLog(@"Resetting............................")
            break;
        case CBCentralManagerStateUnauthorized:
            SCLog(@"Unauthorized............................")
            break;
        case CBCentralManagerStateUnsupported:
            SCLog(@"Unsupported............................")
            break;
        default:
            break;
    }
}

//发现扫描到  peripheral 设备后  进入 该方法(多次进入)
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    //过滤除了标注 myPeripheral 的 蓝牙设备,
//    if ([peripheral.name hasPrefix:@"myPeripheral"]) {
    
        SCLog(@"+_+_+_+_+_+_+_+_+_+_+_+_+ peripheral%@\n--------------------------advertisementData%@\n++++++++++++++++++RRSI%@\n=============================%@",peripheral,advertisementData,RSSI,peripheral.services);
        EqueueSyncMainStart(self.tableVqueue)
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:peripheral forKey:@"peripheral" ];
        [dict setObject:advertisementData forKey:@"advertisementData"];
        [dict setObject:RSSI  forKey:@"RSSI"];
        
        [self updateTableViewWithData:dict];
        EqueueEnd

//    }

}
-(void)updateTableViewWithData:(NSMutableDictionary *)dict
{
    
                  
//    EqueueAsyncMainStart
//    EqueueSyncMainStart(dispatch_get_main_queue())
    EqueueAsyncMainStart(dispatch_get_main_queue())
    [self.deviceArr addObject:dict];
    
    [self.tableView beginUpdates];

    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:self.deviceArr.count-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath1] withRowAnimation:UITableViewRowAnimationAutomatic];

    [self.tableView endUpdates];
//    EqueueAsyncMainEnd
    EqueueEnd
}


//连接成功后,调用
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    SCLog(@"连接成功了 @@@@@@@@@@@@@@@@@@@@@@@@@@@ %@",peripheral);
    
//    EqueueSyncMainStart
    EqueueSyncMainStart(dispatch_get_main_queue())
    self.deviceConnectTF.text = @"Connected";
    //保存 当前 peripheral
    self.currentPeripheral = peripheral;
    
    //restore connect state
    [[NSNotificationCenter defaultCenter] postNotificationName:SLDeviceConnectState object:nil userInfo:@{ @"state" : @YES}];
    
    //停止转 juhua
    [self.juhua stopAnimating];
    
    EqueueEnd
    //设置 peripheral 代理
    peripheral.delegate = self;
    //发现 订阅信息.....
    [peripheral discoverServices:nil];
    
}

//连接外设失败后, 调用
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
    SCLog(@"连接失败了@@@@@@@@@@@@@@@@@@@@@@@@@@@ /n %@",peripheral);
    
}

//取消连接外设后,调用
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;
{
    SCLog(@"取消外设连接..............................\n %@ BOOL = %u",peripheral,self.isSLDeviceConnected)
    [central cancelPeripheralConnection:peripheral];
    
    EqueueSyncMainStart(dispatch_get_main_queue())
    if (self.isSLDeviceConnected) {
        //stop juhua loading
        [self.juhua stopAnimating];
        // disconnect
        self.deviceConnectTF.text = @"Device disconnect";
      
        
    }else{
        //stop juhua loading
        [self.juhua stopAnimating];
        // disconnect
        self.deviceConnectTF.text = @"Connection fail";
        
    }
    EqueueEnd

}




#pragma mark CBPeripheralDelegate  🎥
#pragma mark -------------------------------------------
//连接成功后会,扫描发现 特征服务
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
//    EqueueSyncMainStart
    EqueueSyncMainStart(dispatch_get_main_queue())
    self.deviceConnectTF.text = @"Connected";
    EqueueEnd
    
    CBService* lightBrightnessService;

    //遍历 所有的特征服务, 进行 详细的判断
    for (CBService *service in peripheral.services) {
        /*
        if ([service.UUID.UUIDString isEqualToString:[FSUtility measurementServiceUUID].UUIDString]) {
            //倒车,声波仪
            scanningService = service;
            [peripheral discoverCharacteristics:@[[FSUtility measurementCharacteristicUUID],[FSUtility commandCharacteristicUUID]] forService:scanningService];
            
            
        }else if ([service.UUID.UUIDString isEqualToString:[FSUtility batteryServiceUUID].UUIDString])
        {
            //电池量
            batteryService = service;
            [peripheral discoverCharacteristics:@[[FSUtility batteryCharacteristicUUID]] forService:batteryService];
            
        }else if ([service.UUID.UUIDString isEqualToString:[FSUtility informationServiceUUID].UUIDString])
        {
            //按钮
            infoService = service;
        }
         */
    }
}

//扫描特征值服务,有哪些特征值......
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        SCLog(@"扫描外设的特征失败！%@->%@-> %@",peripheral.name,service.UUID, [error localizedDescription]);
        return;
    }
    SCLog(@"扫描到外设服务特征有：%@->%@->%@",peripheral.name,service.UUID,service.characteristics);
    //遍历所有 数据特征服务, 进行 与 硬件的交互..
    for (CBCharacteristic *aChar in service.characteristics){
        /*
        if (([service.UUID.UUIDString isEqualToString:[FSUtility batteryServiceUUID].UUIDString] &&
             [aChar.UUID.UUIDString isEqualToString:[FSUtility batteryCharacteristicUUID].UUIDString])
            ||
            ([service.UUID.UUIDString isEqualToString:[FSUtility measurementServiceUUID].UUIDString] &&
             [aChar.UUID.UUIDString isEqualToString:[FSUtility measurementCharacteristicUUID].UUIDString]))
        {
            //停车声波仪
            if (![aChar.UUID.UUIDString isEqualToString:[FSUtility batteryCharacteristicUUID].UUIDString] && !aChar.isNotifying) {
                //设置,特征值 通知...
                [peripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            //电量
            if ([aChar.UUID.UUIDString isEqualToString:[FSUtility batteryCharacteristicUUID].UUIDString])
            {
                //读取电量的 特征值.
                [peripheral readValueForCharacteristic:aChar];
                
            }
        }else if ([service.UUID.UUIDString isEqualToString:[FSUtility informationServiceUUID].UUIDString])
        {
            //信号设备
            if ([aChar.UUID.UUIDString isEqualToString:[FSUtility informationACharacteristicUUID].UUIDString])
            {
                [peripheral readValueForCharacteristic:aChar];
                
            }else if([aChar.UUID.UUIDString isEqualToString:[FSUtility informationBCharacteristicUUID].UUIDString])
            {
                //                if ([peripheral isEqual:self.frontSensorPeripheral]) {
                //                    self.FrontVersion = @"v1.0";
                //                }else if([peripheral isEqual:self.rearSensorPeripheral]){
                //                    self.RearVersion = @"v1.0";
                //                }
                //                NSLog(@"This device can not read version information.");
                //                }
            }
        }
        */
        //这里外设需要订阅特征的通知，否则无法收到外设发送过来的数据
        //        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        
    }
    
    
    
    
}


//当特征更新了,就会调用
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    /*
     if ([characteristic.UUID.UUIDString isEqualToString:[FSUtility measurementCharacteristicUUID].UUIDString])
     {
         //停车的数据
         NSData *leftData = [characteristic.value subdataWithRange:NSMakeRange(0, 2)];
         NSData *rightData = [characteristic.value subdataWithRange:NSMakeRange(2, 2)];
     
         NSInteger leftReading = [self _decodedReadingFromData:leftData];
         NSInteger rightReading = [self _decodedReadingFromData:rightData];
     
         NSString *dataStr = [NSString stringWithFormat:@"left:%ld, right:%ld",(long)leftReading,(long)rightReading];
         queueMainStart
         weakself.peripheralDatas.text = dataStr;
         queueMainEnd
     }
     //电池电量
     else if ([characteristic.UUID.UUIDString isEqualToString:[FSUtility batteryCharacteristicUUID].UUIDString])
     {
         [peripheral readValueForCharacteristic:characteristic];
         weakself.batteryDatas = characteristic.value;
     }
     else if ([characteristic.UUID.UUIDString isEqualToString:@"2A06"])
     {
     //
     
     }
     */
    
}



#pragma mark UITableView data source 💾
#pragma mark -------------------------------------------
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceArr.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.frame = CGRectMake(0, 0,tableView.width, 25);
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 1;
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(view.height*0.5-10, 0, view.width, 20)];
    lable.font = [UIFont systemFontOfSize:15];
    lable.text = @"Please select your device.";
    lable.textAlignment = NSTextAlignmentCenter;
    [view addSubview:lable];
    return view;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DeviceNameCell class]) forIndexPath:indexPath];
    
    NSDictionary *dict = self.deviceArr[indexPath.row];
    
    [cell configCellWithData:[dict[eDeviceNameKey] name]];
    
    return cell;
}

#pragma mark UITableViewDelegate 🎥
#pragma mark -------------------------------------------
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //停止扫描....
    [self.centralManager stopScan];
    NSDictionary *dict = self.deviceArr[indexPath.row];
    
    //选中后, 显示到 deviceTF..
    self.deviceNameTF.text = [dict[eDeviceNameKey] name];
    self.deviceConnectTF.text = @"Connecting";
    
    //连接选中的 peripheral....
    //CBConnectPeripheralOptionNotifyOnDisconnectionKey 这个key 字面意思, 就是 Peripheral断开后 给用户提示
    [self.centralManager connectPeripheral:dict[eDeviceNameKey] options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey : @YES }];

    //记录是否已经进行连接
    [[NSNotificationCenter defaultCenter] postNotificationName:SLDeviceConnectState object:nil userInfo:@{ @"state" : @NO}];

    //添加按钮 改变 状态
    self.addDeviceBtn.selected = YES;

    //移除tableView
    [self.tableView removeFromSuperview];
    self.tableView = nil;
//
//    //停止转 juhua
//    [self.juhua stopAnimating];
    
}






-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SLDeviceConnectState object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
