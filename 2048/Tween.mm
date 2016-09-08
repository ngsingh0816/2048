//
//  Tween.m
//  2048
//
//  Created by Neil on 4/9/14.
//  Copyright (c) 2014 Neil. All rights reserved.
//

#import "Tween.h"

float MDTweenLinear(float time)
{
	return time;
}

float MDTweenEaseInQuadratic(float time)
{
	return time * time;
}

float MDTweenEaseOutQuadratic(float time)
{
	return -(time * (time - 2));
}

float MDTweenEaseInOutQuadratic(float time)
{
	if (time < 0.5)
		return 2 * time * time;
	return (-2 * time * time) + (4 * time) - 1;
}

float MDTweenEaseInCubic(float time)
{
	return time * time * time;
}

float MDTweenEaseOutCubic(float time)
{
	float f = time - 1;
	return f * f * f + 1;
}

float MDTweenEaseInOutCubic(float time)
{
	if (time < 0.5)
		return 4 * time * time * time;
	float f = ((2 * time) - 2);
	return (0.5 * f * f * f) + 1;
}

float MDTweenEaseInQuartic(float time)
{
	return time * time * time * time;
}

float MDTweenEaseOutQuartic(float time)
{
	float f = (time - 1);
	return f * f * f * (1 - time) + 1;
}

float MDTweenEaseInOutQuartic(float time)
{
	if (time < 0.5)
		return 8 * time * time * time * time;
	float f = time - 1;
	return -8 * f * f * f * f + 1;
}

float MDTweenEaseInQuintic(float time)
{
	return time * time * time * time * time;
}

float MDTweenEaseOutQuintic(float time)
{
	float f = time - 1;
	return f * f * f * f * f + 1;
}

float MDTweenEaseInOutQuintic(float time)
{
	if (time < 0.5)
		return 16 * time * time * time * time * time;
	float f = (2 * time) - 2;
	return 0.5 * f * f * f * f * f + 1;
}

float MDTweenEaseInSin(float time)
{
	return sinf((time - 1) * M_PI_2) + 1;
}

float MDTweenEaseOutSin(float time)
{
	return sinf(time * M_PI_2);
}

float MDTweenEaseInOutSin(float time)
{
	return 0.5 * (1 - cos(time * M_PI));
}

float MDTweenEaseInExp(float time)
{
	return ((time == 0.0) ? 0.0 : powf(2, 10 * (time - 1)));
}

float MDTweenEaseOutExp(float time)
{
	return ((time == 1.0) ? 1.0 : (1 - powf(2, -10 * time)));
}

float MDTweenEaseInOutExp(float time)
{
	if (time == 0.0 || time == 1.0)
		return time;
	if (time < 0.5)
		return 0.5 * powf(2, (20 * time) - 10);
	return -0.5 * powf(2, (-20 * time) + 10) + 1;
}

float MDTweenEaseInExpX(float time, float base, float exp)
{
	return (pow(base, exp * (time - 1)) - pow(base, -exp)) / (1 - pow(base, -exp));
}

float MDTweenEaseOutExpX(float time, float base, float exp)
{
	return (1 - pow(base, -exp * time)) / (1 - pow(base, -exp));
}

float MDTweenEaseInOutExpX(float time, float base, float exp)
{
	float val = (-pow(base, -exp) + 1);
	float val1 = (0.5 * pow(base, -exp));
	if (time < 0.5)
		return (0.5 * pow(base, exp * (2 * time - 1)) - val1) / val;
	return (-0.5 * pow(base, -exp * (2 * time - 1)) + 1 - val1) / val;
}

float MDTweenEaseInCircle(float time)
{
	return 1 - sqrtf(1 - time * time);
}

float MDTweenEaseOutCircle(float time)
{
	return sqrtf((2 - time) * time);
}

float MDTweenEaseInOutCircle(float time)
{
	if (time < 0.5)
		return 0.5 * (1 - sqrtf(1 - 4 * time * time));
	return 0.5 * (sqrtf(-((2 * time) - 3) * ((2 * time) - 1)) + 1);
}

float MDTweenEaseInElastic(float time)
{
	return sinf(13 * M_PI_2 * time) * powf(2, 10 * (time - 1));
}

float MDTweenEaseOutElastic(float time)
{
	return sinf(-13 * M_PI_2 * (time + 1)) * powf(2, -10 * time) + 1;
}

float MDTweenEaseInOutElastic(float time)
{
	if (time < 0.5)
		return 0.5 * sinf(13 * M_PI_2 * (2 * time)) * powf(2, 10 * ((2 * time) - 1));
	else
		return 0.5 * (sinf(-13 * M_PI_2 * ((2 * time - 1) + 1)) * powf(2, -10 * (2 * time - 1)) + 2);
}

float MDTweenEaseInBack(float time)
{
	return time * time * time - time * sinf(time * M_PI);
}

float MDTweenEaseOutBack(float time)
{
	float f = (1 - time);
	return 1 - (f * f * f - f * sinf(f * M_PI));
}

float MDTweenEaseInOutBack(float time)
{
	if (time < 0.5)
	{
		float f = 2 * time;
		return 0.5 * (f * f * f - f * sinf(f * M_PI));
	}
	else
	{
		float f = (1 - (2 * time - 1));
		return 0.5 * (1 - (f * f * f - f * sinf(f * M_PI))) + 0.5;
	}
}

float MDTweenEaseInBounce(float time)
{
	return 1 - MDTweenEaseOutBounce(1 - time);
}

float MDTweenEaseOutBounce(float time)
{
	if (time < 4.0 / 11.0)
		return (121.0 * time * time) / 16.0;
	else if (time < 8.0 / 11.0)
		return (363.0 / 40.0 * time * time) - (99.0 / 10.0 * time) + 17.0 / 5.0;
	else if (time < 9.0 / 10.0)
		return (4356.0 / 361.0 * time * time) - (35442.0 / 1805.0 * time) + 16061.0 / 1805.0;
	else
		return (54.0 / 5.0 * time * time) - (513.0 /25.0 * time) + 268.0 /25.0;
}

float MDTweenEaseInOutBounce(float time)
{
	if (time < 0.5)
		return 0.5 * MDTweenEaseInBounce(time * 2);
	else
		return 0.5 * MDTweenEaseOutBounce(time * 2 - 1) + 0.5;
}