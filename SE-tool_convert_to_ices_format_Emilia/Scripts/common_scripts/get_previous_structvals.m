function ices_info=get_previous_structvals(ices_info,ices_struct,html_currpos,matpath)
structStartDate=datestr(ices_struct.time_vec(1),'yyyy-mm');
i_html=find(arrayfun(@(x) strcmp(x.startDate(1:7),structStartDate),html_currpos), 1);
%Find versionnumber online if exist
if ~isempty(i_html)
    version_html=html_currpos(i_html).datasetVersion;
    version=['v1.' num2str(str2double(version_html(end))+1)];
    DataUUID=html_currpos(i_html).dataUUID;
    disp(['File exists on web: new version: ' version])
else
    version='v1.0';
    DataUUID=char(java.util.UUID.randomUUID);
    disp(['No file in database, current version: ' version])
end

ices_info.version=version;
ices_info.DataUUID=DataUUID;
dir_mat=dir([matpath '*.mat*']);
structStartDate=datestr(ices_struct.time_vec(1),'yymm');
i_mat=find(arrayfun(@(x) strcmp(x.name(15:18),structStartDate),dir_mat), 1);
if ~isempty(i_mat)
    s=matfile(fullfile(dir_mat(i_mat).folder,dir_mat(i_mat).name));
    dset=s.dset;
    ices_info.comments=dset.Metadata.Comments;
else
    ices_info.comments='';
end
