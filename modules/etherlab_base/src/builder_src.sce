// ====================================================================
// Allan CORNET
// Simon LIPP
// INRIA 2008
// ====================================================================

src_dir = get_absolute_file_path('builder_src.sce');

tbx_builder_src_lang('fortran', src_dir);
tbx_builder_src_lang('c', src_dir);
tbx_builder_src_lang('tcl', src_dir);

clear tbx_builder_src_lang;
clear src_dir;

