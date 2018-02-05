

purge
% delete timers:
delete(timerfind)

cJavaLibPath = pwd;
app = lsicontrol.ui.LSI_Control('cJavaLibPath', cJavaLibPath);

%%
app.build()

if strcmp(char(java.lang.System.getProperty('user.name')), 'rhmiyakawa')
    drawnow
%     app.hFigure.Position = [29        -165        1750        1000];
%    lsi.hFigure.Position = [-3966         500        1600         1000];
end