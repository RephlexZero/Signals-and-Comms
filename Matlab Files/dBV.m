function decibels = dBV(z)
  az=abs(z);
  if (az>1.0e-10)
    decibels=20.0*log10((az));
  else
    decibels=-200.0;
  end;
end