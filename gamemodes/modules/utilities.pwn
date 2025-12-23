CreateRandomString(destination[], length = sizeof destination)
{
	new bool:useCaps = false;

	while (length--)
	{
		useCaps = bool:random(2);

		destination[length] = (useCaps) ? RandomRange('A', 'Z') : RandomRange('a', 'z');
	}
}

RandomRange(min, max)
{
	return random(max - min) + min;
}

Float:FloatClamp(Float:value, Float:min, Float:max)
{
	new Float:newValue = value;

	if (value < min)
	{
		newValue = min;
	}
	else if (value > max)
	{
		newValue = max;
	}

	return newValue;
}