//
//  HTXcodeIMFix.m
//  XcodeIMFix

#import "HTXcodeIMFix.h"
#import <objc/message.h>


@implementation HTXcodeIMFix
IMP origHTXcodeIMFixSetMarkedTextImp;
static void repHTXcodeIMFixSetMarkedTextImp(id self, SEL _cmd, id aString, NSRange selRange){
    
    id   completionController=objc_msgSend(self, @selector(completionController));
    BOOL isShowingCompletions=(BOOL)objc_msgSend(completionController, @selector(isShowingCompletions));
    
    if(isShowingCompletions){
        //if completion is shown ignore InputMethod
        //NSLog(@"isShowingCompletions");
    }else{
        //call original
        origHTXcodeIMFixSetMarkedTextImp(self, _cmd,aString,selRange);
    }
}


IMP HTXcodeIMFixReplaceMethodImpWithFunc(Class aClass, SEL origSel, const void* repFunc)
{
    Method origMethod;
    IMP oldImp = NULL;

    if (aClass && (origMethod = class_getInstanceMethod(aClass, origSel))){
        oldImp=method_setImplementation(origMethod, repFunc);
    }
    return oldImp;
}


+ (void)pluginDidLoad:(NSBundle *)plugin
{
    Class textView=NSClassFromString(@"DVTSourceTextView");
    Class completionController=NSClassFromString(@"DVTTextCompletionController");
    if (textView && completionController
        && [textView instancesRespondToSelector:@selector(completionController)]
        && [completionController instancesRespondToSelector:@selector(isShowingCompletions)]) {
        
        origHTXcodeIMFixSetMarkedTextImp = HTXcodeIMFixReplaceMethodImpWithFunc(textView,
                                        @selector(setMarkedText:selectedRange:), repHTXcodeIMFixSetMarkedTextImp);
        
    }
    
    if(origHTXcodeIMFixSetMarkedTextImp){
        NSLog(@"HTXcodeIMFix pluginDidLoad successfully.");
    }else{
        NSLog(@"HTXcodeIMFix pluginDidLoad but faild raplace method.");
    }
    
    
}


@end
