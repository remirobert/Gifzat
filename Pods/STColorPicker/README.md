# STColorPicker

A color picker presented in a UIView (you can add this color picker to a UIPopoverController or a simple UIViewController).

![STColorPicker screenshot](https://raw.github.com/SebastienThiebaud/STColorPicker/master/screenshot.png "STColorPicker Screenshot")

## Installation

Please use CocoaPods and include STColorPicker in your Podfile.

## Demo

Build and run the project STColorPickerExample in Xcode to see `STColorPicker` in action. 

## Example Usage

``` objective-c
STColorPicker *colorPicker = [[STColorPicker alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 180.0)];
[colorPicker setColorHasChanged:^(UIColor *color, CGPoint location) {
    NSLog(@"New color: %@", color);
}];
[self.view addSubview:colorPicker];
```

## Contact

Sebastien Thiebaud

- http://github.com/SebastienThiebaud
- http://twitter.com/SebThiebaud

## License

STColorPicker is available under the MIT license.

