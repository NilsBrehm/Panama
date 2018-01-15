function q = artifical_moth(t,amp,f, dumping, xshift)
q = exp(-t/dumping).*amp.*sin(f*(t+xshift));
end