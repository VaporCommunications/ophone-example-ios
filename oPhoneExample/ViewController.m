//
//  ViewController.m
//  oPhoneExample
//
//  Created by Brendan Regan on 7/3/15.
//  Copyright (c) 2015 Vapor Communications. All rights reserved.
//

#import "ViewController.h"
#import <oPhoneBluetoothSevenSDK/OPBTPeripheral.h>
#import <oPhoneBluetoothSevenSDK/OPBTSettingsRegistry.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *log;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *smellNames;
@property (nonatomic, strong) NSArray *smellCodes;


@property(nonatomic,strong) OPBTCentralManager* opbtManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self setupoPhone];
    [self appendToTextView:@"started"];
    
    [self.tableView reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self.opbtManager scanForPeripheralDevices];
}

- (void)setupoPhone {
    self.opbtManager = [[OPBTCentralManager alloc] initWithDelegate:self];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peripheralDidConnect:) name:OPBTPeripheralConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peripheralDidDisconnect:) name:OPBTPeripheralDisconnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peripheralDidAcknowledgeData:) name:OPBTPeripheralDataQueueAcknowledgedNotification object:nil];
    
    
    
    // Use some example smells from the "Coffee" scent family
    self.smellNames = [NSArray arrayWithObjects:@"Passion Fruit",
                       @"Citrus",
                       @"Jasmine",
                       @"Green Vegetation",
                       @"Honey",
                       @"Exotic Wood",
                       @"Apricot",
                       @"Red Berries",
                       @"Cedar",
                       @"Licorice",
                       @"Butter",
                       @"Caramel",
                       @"Cocoa Bean",
                       @"Walnut",
                       @"Grilled Toast",
                       @"Cream", nil];
    
    self.smellCodes = [NSArray arrayWithObjects:@"M",
                       @"E",
                       @"H",
                       @"J",
                       @"M",
                       @"O",
                       @"R",
                       @"T",
                       @"c",
                       @"e",
                       @"h",
                       @"j",
                       @"m",
                       @"o",
                       @"r",
                       @"t", nil];
    

    

    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .2f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        [self.opbtManager scanForPeripheralDevices];
//    });
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)appendToTextView: (NSString*) moreText {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog( @"%@", moreText );
        self.log.text = [NSString stringWithFormat:@"%@%@\n",
                           self.log.text, moreText];
        [self.log scrollRangeToVisible:NSMakeRange(self.log.text.length-1, 1)];
    });
}


-(NSError*)sendSmell:(NSString*)smellId withDuration:(Byte)duration toPeripheral:(OPBTPeripheral *)peripheral
{
    if(peripheral == nil) {
        return  [NSError errorWithDomain:OPBTPeripheralDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:@"No peripherals connected."}];
    }
    
    if(peripheral.isReadyForWriting) {
        char bytes[] = "\x40\x05\x6D";
        bytes[1] = duration;
        
        const char *c = [smellId UTF8String];
        bytes[2] = c[0];
        
        size_t length = (sizeof bytes) - 1;
        NSData *data = [NSData dataWithBytes:bytes length:length];
        
        [peripheral enqueueData:data context:@"1"];
    } else {
        return  [NSError errorWithDomain:OPBTPeripheralDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:@"Peripheral not ready for writing."}];
    }
    
    return nil;
}


-(void)peripheralDidConnect:(NSNotification*)note
{
    [self appendToTextView:@"peripheralDidConnect"];
    
    // We can stop scanning now that we found a peripheral.
    [self.opbtManager stopScan];
}

-(void)peripheralDidDisconnect:(NSNotification*)note
{
    [self appendToTextView:@"peripheralDidDisconnect"];
}

-(void)peripheralDidAcknowledgeData:(NSNotification*)note
{
    [self appendToTextView:@"peripheralDidAcknowledgeData"];
}

-(void) centralManager:(OPBTCentralManager *)manager didEncounterConnectionError:(NSError*)error
{
    NSString *str = [NSString stringWithFormat:@"didEncounterConnectionError %@", error.localizedDescription];
    [self appendToTextView:str];
}

-(void)centralManagerDidConnect:(OPBTCentralManager *)manager
{
    [self appendToTextView:@"centralManagerDidConnect"];
}

-(void)centralManagerDidDisconnect:(OPBTCentralManager *)manager
{
    [self appendToTextView:@"centralManagerDidDisconnect"];
}

-(void) centralManager:(OPBTCentralManager *)manager didRegisterValidPeripheral:(OPBTPeripheral *)peripheral
{
    [peripheral connectWithCompletionHandler:nil];
    [self appendToTextView:@"didRegisterValidPeripheral"];
}

-(void) centralManager:(OPBTCentralManager *)manager didDeregisterValidPeripheral:(OPBTPeripheral *)peripheral
{
    [self appendToTextView:@"didDeregisterValidPeripheral"];
}



#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.smellNames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"UITableViewCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [self.smellNames objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Send a smell to the device when its button is pressed
    NSInteger row = indexPath.row;
    NSString *smellName = [self.smellNames objectAtIndex:row];
    NSString *smellCode = [self.smellCodes objectAtIndex:row];
    NSInteger smellDuration = 15;
    
    [self appendToTextView:[NSString stringWithFormat:@"Sending smell %@ (%@) for duration %ld seconds.", smellName, smellCode, (long)smellDuration]];
    
    NSError *error = [self sendSmell:smellCode withDuration:smellDuration toPeripheral:[self.opbtManager.currentPeripherals anyObject]];
    if (error) {
        [self appendToTextView:[NSString stringWithFormat:@"Error sending smell: %@", error.localizedDescription]];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
@end
