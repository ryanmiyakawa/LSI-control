function getGuidePostitions(h)


children = h.Children;

for k = 1:length(children)
   set(h.Children(k), 'Units', 'pixels');
   pos = get(h.Children(k), 'Position');
   
   fprintf('Child %s has position:\n', class(h.Children(k)));
   disp(pos);
    
end