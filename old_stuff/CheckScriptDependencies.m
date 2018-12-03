clc
script_name = 'activeorpassive';
[fList,pList] = matlab.codetools.requiredFilesAndProducts([script_name, '.m']);

disp(['Dependencies of ', script_name, ': '])
for k=1:length(fList)
    disp(fList(k))
end
    