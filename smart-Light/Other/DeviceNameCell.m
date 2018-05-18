//
//  DeviceNameCell.h
//  smart-Light
//
//  Created by edward on 27/11/17.
//  Copyright © 2017年 Edward. All rights reserved.
//

#import "DeviceNameCell.h"
#import "UITableViewCell+Help.h"

@interface DeviceNameCell ()

@property (weak, nonatomic) IBOutlet UILabel *deviceNameL;


@end

@implementation DeviceNameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(void)configCellWithData:(NSString *)data
{
    
    if (data) {
        self.deviceNameL.text = data;
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
