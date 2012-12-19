function out = filesep()
  if ~(getos() == "Windows") then
    out='/';
  else
    out='\';
  end;
endfunction