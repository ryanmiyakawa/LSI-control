a = 1:10
vals = [5 7 9]
push = 1;

for n=1:length(vals)
    index = find(a == vals(n));
    a([index index-push]) = a([index-push index]);
    
end

a