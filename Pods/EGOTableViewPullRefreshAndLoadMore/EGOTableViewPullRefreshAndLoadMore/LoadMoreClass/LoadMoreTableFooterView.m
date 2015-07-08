
#import "LoadMoreTableFooterView.h"


#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f


@interface LoadMoreTableFooterView (Private)
- (void)setState:(PullLoadMoreState)aState;
@end

@implementation LoadMoreTableFooterView

- (id)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor  {
    if((self = [super initWithFrame:frame])) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];

				
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 65 - 48.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:13.0f];
		label.textColor = textColor;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(25.0f, 0, 30.0f, 55.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:arrow].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        view.frame = CGRectMake(25.0f, label.frame.origin.y, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		
		[self setState:PullLoadMoreNormal];
    }
	
    return self;
	
}

- (id)initWithFrame:(CGRect)frame  {
  return [self initWithFrame:frame arrowImageName:@"blueArrowLoadMore.png" textColor:TEXT_COLOR];
}

#pragma mark -
#pragma mark Setters


- (void)setState:(PullLoadMoreState)aState{
	
	switch (aState) {
		case PullLoadMorePulling:
			
			_statusLabel.text = NSLocalizedString(@"Release to load more...", @"Release to load more status");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case PullLoadMoreNormal:
			
			if (_state == PullLoadMorePulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			_statusLabel.text = NSLocalizedString(@"Pull up to load more...", @"Pull up to load more status");
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			
			
			break;
            
		case PullLoadMoreLoading:
			
			_statusLabel.text = NSLocalizedString(@"Loading more...", @"Loading Status");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)loadMoreScrollViewDidScroll:(UIScrollView *)scrollView
{
	if (_state == PullLoadMoreLoading)
    {
		
		/*CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);*/
		
	}
    else if (scrollView.isDragging)
    {
		
		BOOL _loading = NO;
		if ([self.delegate respondsToSelector:@selector(loadMoreTableFooterDataSourceIsLoading:)])
        {
			_loading = [self.delegate loadMoreTableFooterDataSourceIsLoading:self];
		}
		
		if (_state == PullLoadMorePulling && scrollView.contentOffset.y < (scrollView.contentSize.height - scrollView.bounds.size.height +  65) && scrollView.contentOffset.y > 0.0f && !_loading)
        {
			[self setState:PullLoadMoreNormal];
		}
        else if (_state == PullLoadMoreNormal && scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.bounds.size.height +  65) && !_loading)
        {
			[self setState:PullLoadMorePulling];
		}
		
		/*if (scrollView.contentInset.top != 0)
        {
			scrollView.contentInset = UIEdgeInsetsZero;
		}*/
	}
}

- (void)loadMoreScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([self.delegate respondsToSelector:@selector(loadMoreTableFooterDataSourceIsLoading:)]) {
		_loading = [self.delegate loadMoreTableFooterDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.bounds.size.height +  65) && !_loading)
    {
		
		if ([self.delegate respondsToSelector:@selector(loadMoreTableFooterDidTriggerLoadMore:)]) {
			[self.delegate loadMoreTableFooterDidTriggerLoadMore:self];
		}
		
		[self setState:PullLoadMoreLoading];
        
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
		[UIView commitAnimations];
	}
}

- (void)loadMoreScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:PullLoadMoreNormal];

}


@end
