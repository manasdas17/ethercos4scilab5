// ====================================================================
// Allan CORNET
// Simon LIPP
// INRIA 2008
// ====================================================================

src_dir = get_absolute_file_path('builder_src.sce');

if isdir(pathconvert(src_dir+"/fortran",%F)) then
    tbx_builder_src_lang("fortran", src_dir);
end;
if isdir(pathconvert(src_dir+"/c",%F)) then
    tbx_builder_src_lang("c", src_dir);
end;
clear tbx_builder_src_lang;
clear src_dir;

