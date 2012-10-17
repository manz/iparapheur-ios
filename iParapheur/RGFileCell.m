//
//  RGFileCell.m
//  iParapheur
//
//  Created by Emmanuel Peralta.


#import "RGFileCell.h"

@implementation RGFileCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib {
    _retardBadge = [CustomBadge customBadgeWithString:@""];
    
    //[self addSubview:_lateBadge];
    [_retardBadge setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin];
    [_retardPlaceHolder addSubview:_retardBadge];
    [_filenameLabel setLineBreakMode:NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
