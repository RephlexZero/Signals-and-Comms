function filtered_sig = LPF_Butterworth(w,wc,n)
  if (wc>0.0)
    filtered_sig=1.0/(1.0 + (w/wc)^(2*n));
  else
    filtered_sig=0.0;
  end;
end