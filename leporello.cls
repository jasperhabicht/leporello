% File: leporello.cls
% Copyright 2025 Jasper Habicht (mail(at)jasperhabicht.de).
%
% This work may be distributed and/or modified under the
% conditions of the LaTeX Project Public License version 1.3c,
% available at http://www.latex-project.org/lppl/.
%
% This file is part of the `leporello' package (The Work in LPPL)
% and all files in that bundle must be distributed together.
%
% This work has the LPPL maintenance status `maintained'.
%
\ProvidesExplClass{leporello}
  {2025/08/12} {0.8.0} {Document class for typesetting folding flyers}

\cs_generate_variant:Nn \clist_item:Nn { NV }
\cs_generate_variant:Nn \color_select:n { e }
\cs_generate_variant:Nn \coffin_attach:NnnNnnnn { ceeceeee }
\cs_generate_variant:Nn \prop_gput:Nnn { cnV , cne }
\cs_generate_variant:Nn \tl_const:Nn { co }
\cs_generate_variant:Nn \msg_error:nnnn { nneV }

\prg_generate_conditional_variant:Nnn \clist_if_in:nn { en } { T , F , TF }
\prg_generate_conditional_variant:Nnn \str_if_eq:nn { en } { F }

\bool_new:N \l_leporello_show_frames_bool
\bool_new:N \l_leporello_show_id_bool
\bool_new:N \l_leporello_prepress_bool
\dim_new:N \l_leporello_layout_height_dim
\dim_new:N \l_leporello_bleed_dim
\dim_new:N \l_leporello_info_area_dim
\clist_new:N \l_leporello_columns_clist
\int_new:N \l_leporello_column_count_int

\dim_new:N \l__leporello_layout_width_dim
\dim_new:N \l__leporello_paper_width_dim
\dim_new:N \l__leporello_paper_height_dim

\keys_define:nn { leporello / global } {
  columns           .code:n     = {
    \clist_set:Nn \l_leporello_columns_clist {#1}
    \int_set:Nn \l_leporello_column_count_int {
      \clist_count:N \l_leporello_columns_clist
    }
    \dim_zero:N \l__leporello_layout_width_dim
    \clist_map_inline:Nn \l_leporello_columns_clist {
      \dim_add:Nn \l__leporello_layout_width_dim {##1}
    }
  } ,
  columns           .initial:n  = { 97mm , 100mm , 100mm } ,
  layout ~ height   .dim_set:N  = \l_leporello_layout_height_dim ,
  layout ~ height   .initial:n  = { 210mm } ,
  show ~ frames     .bool_set:N = \l_leporello_show_frames_bool ,
  show ~ frames     .default:n  = { true } ,
  show ~ frames     .initial:n  = { false } ,
  show ~ ids        .bool_set:N = \l_leporello_show_id_bool ,
  show ~ ids        .default:n  = { true } ,
  show ~ ids        .initial:n  = { false } ,
  prepress          .bool_set:N = \l_leporello_prepress_bool ,
  prepress          .default:n  = { true } ,
  prepress          .initial:n  = { false } ,
  bleed             .dim_set:N  = \l_leporello_bleed_dim ,
  bleed             .initial:n  = { 3mm } ,
  info ~ area       .dim_set:N  = \l_leporello_info_area_dim ,
  info ~ area       .initial:n  = { 10mm } ,

  two ~ columns         .meta:n = {
    columns = { 99mm , 99mm }
  } ,
  three ~ columns       .meta:n = {
    columns = { 97mm , 100mm , 100mm }
  } ,
  four ~ columns        .meta:n = {
    columns = { 99mm , 99mm , 99mm , 100mm }
  } ,
  four ~ columns ~ wrap .meta:n = {
    columns = { 97mm , 99mm , 100mm , 101mm }
  } ,
  five ~ columns        .meta:n = {
    columns = { 97mm , 97mm , 97mm , 99mm , 100mm }
  } ,
  six ~ columns         .meta:n = {
    columns = { 99mm , 99mm , 96mm , 96mm , 100mm , 100mm }
  }
}

\msg_new:nnn { leporello } { too-many-columns } {
  \msg_error_text:n { leporello } \iow_newline:
  #1 ~ columns ~ specified ~ for ~ typesetting \iow_newline:
  but ~ only ~ #2 ~ columns ~ defined ~ for ~ layout.
}

\msg_new:nnn { leporello } { box-outside-column } {
  \msg_error_text:n { leporello } \iow_newline:
  Box ~ #1 ~ defined ~ outside ~ column.
}

\msg_new:nnn { leporello } { image-outside-box } {
  \msg_error_text:n { leporello } \iow_newline:
  Image ~ defined ~ outside ~ box.
}

\msg_new:nnn { leporello } { column-undefined } {
  \msg_error_text:n { leporello } \iow_newline:
  Column ~ #1 ~ undefined.
}

\int_new:N \l_leporello_current_page_int
\int_new:N \l_leporello_current_column_int
\str_new:N \l_leporello_current_column_str
\dim_new:N \l_leporello_current_column_offset_dim
\coffin_new:N \l_leporello_current_column_coffin

\int_new:N \g_leporello_box_int
\int_new:N \l_leporello_current_box_int
\clist_new:N \g_leporello_parent_boxes_clist

\tl_new:N \l__leporello_box_align_parent_clist
\tl_new:N \l__leporello_box_align_self_clist
\tl_new:N \l__leporello_box_offset_clist
\bool_new:N \l__leporello_box_width_bool
\bool_new:N \l__leporello_box_height_bool
\dim_new:N \l__leporello_box_width_dim
\dim_new:N \l__leporello_box_height_dim
\tl_new:N \l__leporello_box_store_width_tl
\tl_new:N \l__leporello_box_store_height_tl
\dim_new:N \l__leporello_box_padding_left_dim
\dim_new:N \l__leporello_box_padding_right_dim
\dim_new:N \l__leporello_box_padding_top_dim
\dim_new:N \l__leporello_box_padding_bottom_dim
\tl_new:N \l__leporello_box_pre_tl
\tl_new:N \l__leporello_box_background_color_tl
\tl_new:N \l__leporello_box_background_code_tl
\box_new:N \l__leporello_box_background_box
\clist_new:N \l__leporello_box_bleed_clist

\dim_new:N \l__leporello_typeset_box_width_dim
\dim_new:N \l__leporello_typeset_box_height_dim
\dim_new:N \l__leporello_typeset_box_bleed_left_dim
\dim_new:N \l__leporello_typeset_box_bleed_top_dim
\dim_new:N \l__leporello_typeset_box_bleed_x_dim
\dim_new:N \l__leporello_typeset_box_bleed_y_dim
\int_new:N \l__leporello_typeset_coffin_attach_align_int
\box_new:N \l__leporello_typeset_column_box
\coffin_new:N \l__leporello_typeset_mark_coffin
\coffin_new:N \l__leporello_typeset_mark_temp_coffin

\keys_define:nn { leporello / box } {
  parent             .code:n = {
    \clist_if_exist:cF { g_leporello_box_ #1 _children_clist } {
      \clist_new:c { g_leporello_box_ #1 _children_clist }
    }
    \clist_gput_right:cV { g_leporello_box_ #1 _children_clist } \g_leporello_box_int
    \clist_gput_right:NV \g_leporello_parent_boxes_clist \g_leporello_box_int
  } ,
  align ~ parent     .clist_set:N = \l__leporello_box_align_parent_clist ,
  align ~ parent     .initial:n   = { l , t } ,
  align ~ self       .clist_set:N = \l__leporello_box_align_self_clist ,
  align ~ self       .initial:n   = { l , t } ,
  offset             .clist_set:N = \l__leporello_box_offset_clist ,
  offset             .initial:n   = { 0mm , 0mm } ,
  width              .code:n      = {
    \bool_set_true:N \l__leporello_box_width_bool
    \dim_set:Nn \l__leporello_box_width_dim {#1}
  } ,
  height             .code:n      = {
    \bool_set_true:N \l__leporello_box_height_bool
    \dim_set:Nn \l__leporello_box_height_dim {#1}
  } ,
  stretch ~ height   .bool_set:N  = \l__leporello_box_stretch_height_bool ,
  stretch ~ height   .default:n   = { true } ,
  stretch ~ height   .initial:n   = { false } ,
  padding / left     .dim_set:N   = \l__leporello_box_padding_left_dim ,
  padding / right    .dim_set:N   = \l__leporello_box_padding_right_dim ,
  padding / top      .dim_set:N   = \l__leporello_box_padding_top_dim ,
  padding / bottom   .dim_set:N   = \l__leporello_box_padding_bottom_dim ,
  padding            .code:n      = { \keys_set:nn { leporello / box / padding } {#1} } ,
  padding            .initial:n   = {
    left   = 7.5mm ,
    right  = 7.5mm ,
    top    = 7.5mm ,
    bottom = 7.5mm
  } ,
  no ~ padding       .meta:n      = {
    padding = {
      left   = 0mm ,
      right  = 0mm ,
      top    = 0mm ,
      bottom = 0mm
    }
  } ,
  pre                .tl_set:N    = \l__leporello_box_pre_tl ,
  background ~ color .tl_set:N    = \l__leporello_box_background_color_tl ,
  background ~ color .initial:n   = { none } ,
  background ~ code  .tl_set:N    = \l__leporello_box_background_code_tl ,
  bleed              .clist_set:N = \l__leporello_box_bleed_clist ,
  store ~ width      .tl_set:N    = \l__leporello_box_store_width_tl ,
  store ~ height     .tl_set:N    = \l__leporello_box_store_height_tl
}

\bool_new:N \l_leporello_reverse_layout_bool

\keys_define:nn { leporello / print } {
  reverse ~ layout .bool_set:N = \l_leporello_reverse_layout_bool ,
  reverse ~ layout .default:n  = { true } ,
  reverse ~ layout .initial:n  = { false }
}

\bool_new:N \l_leporello_image_fill_bleed_bool
\bool_new:N \l_leporello_image_width_bool
\bool_new:N \l_leporello_image_height_bool
\bool_new:N \l_leporello_image_clip_width_bool
\bool_new:N \l_leporello_image_clip_height_bool
\dim_new:N \l_leporello_image_width_dim
\dim_new:N \l_leporello_image_height_dim
\dim_new:N \l_leporello_image_clip_width_dim
\dim_new:N \l_leporello_image_clip_height_dim
\dim_new:N \l_leporello_image_offset_x_dim
\dim_new:N \l_leporello_image_offset_y_dim
\dim_new:N \l_leporello_image_outer_offset_left_dim
\dim_new:N \l_leporello_image_outer_offset_right_dim
\dim_new:N \l_leporello_image_outer_offset_top_dim
\dim_new:N \l_leporello_image_outer_offset_bottom_dim
\fp_new:N \l_leporello_image_scale_fp
\clist_new:N \l_leporello_image_options_clist
\box_new:N \l__leporello_image_original_box

\keys_define:nn { leporello / image } {
  width              .code:n      = {
    \bool_set_true:N \l_leporello_image_width_bool
    \dim_set:Nn \l_leporello_image_width_dim {#1} 
  } ,
  height             .code:n      = {
    \bool_set_true:N \l_leporello_image_height_bool
    \dim_set:Nn \l_leporello_image_height_dim {#1} 
  } ,
  clip ~ width       .code:n      = {
    \bool_set_true:N \l_leporello_image_clip_width_bool
    \dim_set:Nn \l_leporello_image_clip_width_dim {#1} 
  } ,
  clip ~ height      .code:n      = {
    \bool_set_true:N \l_leporello_image_clip_height_bool
    \dim_set:Nn \l_leporello_image_clip_height_dim {#1} 
  } ,
  offset             .code:n      = {
    \dim_set:Nn \l_leporello_image_offset_x_dim { \clist_item:nn {#1} { 1 } }
    \dim_set:Nn \l_leporello_image_offset_y_dim { - \clist_item:nn {#1} { 2 } }
  } ,
  offset             .initial:n   = { 0mm , 0mm } ,
  scale              .fp_set:N    = \l_leporello_image_scale_fp ,
  scale              .initial:n   = { 1 } ,
  ignore ~ padding   .clist_set:N = \l_leporello_image_ignore_padding_clist ,
  fill ~ bleed       .bool_set:N  = \l_leporello_image_fill_bleed_bool ,
  fill ~ bleed       .default:n   = { true } ,
  fill ~ bleed       .initial:n   = { false }
}

% ===

\hook_new_pair:nn { leporello / column / before } { leporello / column / after }
\hook_new_pair:nn { leporello / box / before } { leporello / box / after }

% ===

\ProcessKeyOptions [ leporello / global ]
\LoadClass { article }
\RequirePackage { geometry }
\RequirePackage { graphicx }
\RequirePackage { l3draw }

\cs_set_eq:NN \leporello_pagestyle_set:n \pagestyle
\cs_set_eq:NN \leporello_geometry_set:n \geometry
\cs_new_protected:Npn \leoprello_graphics_use:nn #1#2 [
  \includegraphics [ #1 ] {#2}
}

\cs_new_protected:Npn \leporello_draw_absolute:nn #1#2 {
  \draw_begin:
    \bool_set_false:N \l_draw_bb_update_bool
    \draw_transform_shift:n {#1}
    #2
  \draw_end:
  \tex_par:D
  \tex_vfil:D
  \tex_penalty:D -10000
}

\cs_if_exist:NF \draw_set_linewidth:n {
  \cs_set_eq:NN \draw_set_linewidth:n \draw_linewidth:n
}

\cs_new_protected:Npn \__leporello_cropmarks: {
  \draw_begin:
    \bool_set_false:N \l_draw_bb_update_bool
    \draw_set_linewidth:n { .25pt }
    \clist_map_inline:nn { 10mm , \paperwidth - 10mm } {
      \clist_map_inline:nn { -10mm , 10mm - \paperheight } {
        \draw_scope_begin:
          \draw_transform_shift:n {
            ##1 , ####1
          }
          \draw_path_moveto:n {
            \dim_sign:n { ##1 - \paperwidth / 2 } * 5pt , 0pt
          }
          \draw_path_lineto:n {
            \dim_sign:n { ##1 - \paperwidth / 2 } * 20pt , 0pt
          }
          \draw_path_use:n { stroke }
        \draw_scope_end:      
      }
    }
  \draw_end:
}
\cs_new_protected:Npn \__leporello_cropmarks:n #1 {
  \draw_begin:
    \bool_set_false:N \l_draw_bb_update_bool
    \draw_set_linewidth:n { .25pt }
    \draw_scope_begin:
      \draw_transform_shift:n {
        #1 , -10mm
      }
      \draw_path_moveto:n { 0pt , 5pt }
      \draw_path_lineto:n { 0pt , 20pt }
      \draw_path_use:n { stroke }
    \draw_scope_end:
    \draw_scope_begin:
      \draw_transform_shift:n {
        #1 , 10mm - \paperheight
      }
      \draw_path_moveto:n { 0pt , -5pt }
      \draw_path_lineto:n { 0pt , -20pt }
      \draw_path_use:n { stroke }
    \draw_scope_end:
  \draw_end:
}
\cs_new_protected:Npn \__leporello_id_mark:n #1 {
  \draw_begin:
    \bool_set_false:N \l_draw_bb_update_bool
    \draw_path_rectangle:nn { -1.5em , -1.5em } { 3em , 3em }
    \draw_path_use_clear:n { fill }
    \hcoffin_set:Nn \l__leporello_typeset_mark_temp_coffin {
      \color_select:n { white } #1
    }
    \draw_coffin_use:Nnn \l__leporello_typeset_mark_temp_coffin
      { hc } { vc }
  \draw_end:  
}

\hook_gput_code:nnn { begindocument / before } { . } {
  \leporello_pagestyle_set:n { empty }
  \dim_set:Nn \l__leporello_paper_height_dim {
    \l_leporello_layout_height_dim + 2 \l_leporello_info_area_dim
  }
  \dim_set:Nn \l__leporello_paper_width_dim {
    \l__leporello_layout_width_dim + 2 \l_leporello_info_area_dim
  }
  \bool_if:NTF \l_leporello_prepress_bool {
    \leporello_geometry_set:n {
      layoutwidth = \l__leporello_layout_width_dim ,
      layoutheight = \l_leporello_layout_height_dim ,
      layouthoffset = \l_leporello_info_area_dim ,
      layoutvoffset = \l_leporello_info_area_dim ,
      paperwidth = \l__leporello_paper_width_dim ,
      paperheight = \l__leporello_paper_height_dim ,
      margin = 0pt
    }
    \hook_gput_code:nnn { shipout / foreground } { . } {
      \__leporello_cropmarks:
      \dim_set:Nn \l_leporello_current_column_offset_dim {
        \l_leporello_info_area_dim
      }
      \__leporello_cropmarks:n { \l_leporello_current_column_offset_dim }
      \clist_map_inline:Nn \l_leporello_columns_clist {
        \dim_add:Nn \l_leporello_current_column_offset_dim {
          #1
        }
        \__leporello_cropmarks:n { \l_leporello_current_column_offset_dim }
      }
    }
  } {
    \leporello_geometry_set:n {
      paperwidth = \l__leporello_layout_width_dim ,
      paperheight = \l_leporello_layout_height_dim ,
      margin = 0pt
    }
  }
  \dim_set:Nn \tex_topskip:D { 0pt }
  \dim_set:Nn \tex_parindent:D { 0pt }
}

\NewDocumentCommand { \leporelloset } { m } {
  \keys_set:nn { leporello / global } {#1}
}

\NewDocumentCommand { \leporellosetstyle } { m m } {
  \keys_define:nn { leporello / box } {
    #1  .meta:n = {#2}
  }
}

\NewDocumentCommand { \leporelloboxwidth } { } {
  \dim_use:N \l__leporello_typeset_box_width_dim
}

\NewDocumentCommand { \leporellobleed } { } {
  \dim_use:N \l_leporello_bleed_dim
}

\NewDocumentCommand { \leporellocolordefine } { m m m } {
  \color_set:nnn {#1} {#2} {#3}
}

\NewDocumentCommand { \leporellocolorselect } { m } {
  \color_select:n {#1}
}

\NewDocumentCommand { \leporelloimage } { O{} m } {
  \group_begin:
    \keys_set:nn { leporello / image } {#1}

    \int_compare:nNnT { \l_leporello_current_box_int } = { 0 } {
      \msg_error:nn { leporello } { image-outside-box }
    }
  
    \hbox_set:Nn \l__leporello_image_original_box {
      \leoprello_graphics_use:nn { } {#2}
    }

    \bool_if:NF \l_leporello_image_clip_width_bool {
      \dim_set:Nn \l_leporello_image_clip_width_dim {
        \fp_to_dim:n {
          \l_leporello_image_scale_fp *
          \box_wd:N \l__leporello_image_original_box
        }
      }
    }
    \bool_if:NF \l_leporello_image_clip_height_bool {
      \dim_set:Nn \l_leporello_image_clip_height_dim {
        \fp_to_dim:n {
          \l_leporello_image_scale_fp *
          \box_ht:N \l__leporello_image_original_box
        }
      }
    }
    \bool_if:NT \l_leporello_image_width_bool {
      \fp_set:Nn \l_leporello_image_scale_fp {
        \l_leporello_image_width_dim /
        \box_wd:N \l__leporello_image_original_box
      }
    }
    \bool_if:NT \l_leporello_image_height_bool {
      \fp_set:Nn \l_leporello_image_scale_fp {
        \l_leporello_image_height_dim /
        \box_ht:N \l__leporello_image_original_box
      }
    }

    \clist_if_in:NnT \l_leporello_image_ignore_padding_clist { l } {
      \dim_add:Nn \l_leporello_image_outer_offset_left_dim {
        \prop_item:cn {
          g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop
        } { padding ~ left }
      }
      \dim_add:Nn \l_leporello_image_clip_width_dim {
        \prop_item:cn {
          g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop
        } { padding ~ left }
      }
      \skip_add:Nn \tex_hfuzz:D {
        \prop_item:cn {
          g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop
        } { padding ~ left }
      }
    }
    \clist_if_in:NnT \l_leporello_image_ignore_padding_clist { r } {
      \dim_add:Nn \l_leporello_image_outer_offset_right_dim {
        \prop_item:cn {
          g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop
        } { padding ~ right }
      }
      \dim_add:Nn \l_leporello_image_clip_width_dim {
        \prop_item:cn {
          g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop
        } { padding ~ right }
      }
      \skip_add:Nn \tex_hfuzz:D {
        \prop_item:cn {
          g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop
        } { padding ~ right }
      }
    }
    \clist_if_in:NnT \l_leporello_image_ignore_padding_clist { t } {
      \dim_add:Nn \l_leporello_image_outer_offset_top_dim {
        \prop_item:cn {
          g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop
        } { padding ~ top }
      }
    }
    \clist_if_in:NnT \l_leporello_image_ignore_padding_clist { b } {
      \dim_add:Nn \l_leporello_image_outer_offset_bottom_dim {
        \prop_item:cn {
          g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop
        } { padding ~ bottom }
      }
    }

    \bool_if:NT \l_leporello_image_fill_bleed_bool {
      \int_compare:nNnT {
        \l_leporello_current_column_int
      } = { 1 } {
        \clist_if_in:enT {
          \prop_item:cn {
            g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop
          } { bleed }
        } { l } {
          \dim_add:Nn \l_leporello_image_outer_offset_left_dim {
            \l_leporello_bleed_dim
          }
          \dim_add:Nn \l_leporello_image_clip_width_dim {
            \l_leporello_bleed_dim
          }
        }
      }
      \int_compare:nNnT { 
        \l_leporello_current_column_int
      } = { \l_leporello_column_count_int } {
        \clist_if_in:enT {
          \prop_item:cn {
            g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop 
          } { bleed }
        } { r } {
          \dim_add:Nn \l_leporello_image_outer_offset_right_dim {
            \l_leporello_bleed_dim
          }
          \dim_add:Nn \l_leporello_image_clip_width_dim {
            \l_leporello_bleed_dim
          }
        }
      }
      \clist_if_in:enT {
        \prop_item:cn {
          g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop
        } { bleed }
      } { t } {
        \dim_add:Nn \l_leporello_image_outer_offset_top_dim {
          \l_leporello_bleed_dim
        }
        \dim_add:Nn \l_leporello_image_clip_height_dim {
          \l_leporello_bleed_dim
        }
      }
      \clist_if_in:enT {
        \prop_item:cn {
          g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop
        } { bleed }
      } { b } {
        \dim_add:Nn \l_leporello_image_outer_offset_bottom_dim {
          \l_leporello_bleed_dim
        }
        \dim_add:Nn \l_leporello_image_clip_height_dim {
         \l_leporello_bleed_dim
        }
      }
    }

    \dim_add:Nn \l_leporello_image_offset_y_dim {
      \fp_to_dim:n {
        \l_leporello_image_scale_fp *
        \box_ht:N \l__leporello_image_original_box -
        \l_leporello_image_clip_height_dim
      }
    }

    \skip_vertical:n { - \l_leporello_image_outer_offset_top_dim }
    \skip_horizontal:n { - \l_leporello_image_outer_offset_left_dim }
    \leoprello_graphics_use:nn {
      scale = \fp_to_decimal:N \l_leporello_image_scale_fp ,
      clip ,
      viewport =
        \dim_to_decimal_in_bp:n {
          \fp_to_dim:n {
            \l_leporello_image_offset_x_dim /
            \l_leporello_image_scale_fp
          }
        } ~
        \dim_to_decimal_in_bp:n {
          \fp_to_dim:n {
            \l_leporello_image_offset_y_dim /
            \l_leporello_image_scale_fp
          }
        } ~
        \dim_to_decimal_in_bp:n {
          \fp_to_dim:n {
            ( 
              \l_leporello_image_clip_width_dim +
              \l_leporello_image_offset_x_dim
            ) / \l_leporello_image_scale_fp
          }
        } ~
        \dim_to_decimal_in_bp:n {
          \fp_to_dim:n {
            (
              \l_leporello_image_clip_height_dim +
              \l_leporello_image_offset_y_dim
            ) / \l_leporello_image_scale_fp
          }
        }
    } {#2}
    \skip_horizontal:n { - \l_leporello_image_outer_offset_right_dim }
    \skip_vertical:n { - \l_leporello_image_outer_offset_bottom_dim }
  \group_end:
}

\NewDocumentEnvironment { leporellocolumn } { m +b } {
  \clist_new:c { g_leporello_column_ #1 _boxes_clist }
  \tl_if_exist:cF { g_leporello_column_ #1 _tl } {
    \tl_new:c { g_leporello_column_ #1 _tl }
  }
  \tl_gset:cn { g_leporello_column_ #1 _tl } {
    \clist_gclear:c { g_leporello_column_ #1 _boxes_clist }
    #2
  }
} { }

\cs_new_protected:Npn \__leporello_box_store:nn #1#2 {
  \tl_if_exist:cF { g_leporello_box_ #1 _tl } {
    \tl_new:c { g_leporello_box_ #1 _tl }
  }
  \tl_gput_right:cn { g_leporello_box_ #1 _tl } {
    \int_set:Nn \l_leporello_current_box_int {#1}
    \prop_item:cn { g_leporello_box_ #1 _prop } { pre }
    #2
  }
}
\cs_generate_variant:Nn \__leporello_box_store:nn { Vn }

\NewDocumentEnvironment { leporellobox } { O{} +b } {
  \group_begin:
    \int_gincr:N \g_leporello_box_int
    
    \str_if_empty:NT \l_leporello_current_column_str {
      \msg_error:nnV { leporello } { box-outside-column }
        \g_leporello_box_int
    }

    \clist_gput_right:cV {
      g_leporello_column_ \str_use:N \l_leporello_current_column_str _boxes_clist
    } \g_leporello_box_int

    \prop_new:c { g_leporello_box_ \int_use:N \g_leporello_box_int _prop }
    \keys_set:nn { leporello / box } {#1}
    \prop_gput:cne { g_leporello_box_ \int_use:N \g_leporello_box_int _prop }
      { align ~ parent }
      { \clist_use:Nn \l__leporello_box_align_parent_clist { , } }
    \prop_gput:cne { g_leporello_box_ \int_use:N \g_leporello_box_int _prop }
      { align ~ self }
      { \clist_use:Nn \l__leporello_box_align_self_clist { , } }
    \prop_gput:cne { g_leporello_box_ \int_use:N \g_leporello_box_int _prop }
      { offset }
      { \clist_use:Nn \l__leporello_box_offset_clist { , } }
    \bool_if:NT \l__leporello_box_width_bool {
      \prop_gput:cnV { g_leporello_box_ \int_use:N \g_leporello_box_int _prop }
        { width }
        \l__leporello_box_width_dim
    }
    \bool_if:NT \l__leporello_box_height_bool {
      \prop_gput:cnV { g_leporello_box_ \int_use:N \g_leporello_box_int _prop }
        { height }
        \l__leporello_box_height_dim
    }
    \prop_gput:cne { g_leporello_box_ \int_use:N \g_leporello_box_int _prop }
      { stretch ~ height }
      { \bool_if_p:N \l__leporello_box_stretch_height_bool }
    \prop_gput:cnV { g_leporello_box_ \int_use:N \g_leporello_box_int _prop }
      { padding ~ left }
      \l__leporello_box_padding_left_dim
    \prop_gput:cnV { g_leporello_box_ \int_use:N \g_leporello_box_int _prop }
      { padding ~ right }
      \l__leporello_box_padding_right_dim
    \prop_gput:cnV { g_leporello_box_ \int_use:N \g_leporello_box_int _prop }
      { padding ~ top }
      \l__leporello_box_padding_top_dim
    \prop_gput:cnV { g_leporello_box_ \int_use:N \g_leporello_box_int _prop }
      { padding ~ bottom }
      \l__leporello_box_padding_bottom_dim
    \prop_gput:cno { g_leporello_box_ \int_use:N \g_leporello_box_int _prop }
      { pre }
      { \l__leporello_box_pre_tl }
    \prop_gput:cnV { g_leporello_box_ \int_use:N \g_leporello_box_int _prop }
      { background ~ color }
      \l__leporello_box_background_color_tl
    \prop_gput:cno { g_leporello_box_ \int_use:N \g_leporello_box_int _prop }
      { background ~ code }
      { \l__leporello_box_background_code_tl }
    \prop_gput:cne { g_leporello_box_ \int_use:N \g_leporello_box_int _prop }
      { bleed }
      { \clist_use:Nn \l__leporello_box_bleed_clist { , } }

    \tl_if_empty:NF \l__leporello_box_store_width_tl {
      \tl_const:co { c_leporello_box_ \int_use:N \g_leporello_box_int _store_width_tl } {
        \l__leporello_box_store_width_tl
      }
      \exp_args:No \tl_if_empty:NF { \l__leporello_box_store_width_tl } {
        \exp_args:No \dim_new:N { \l__leporello_box_store_width_tl }
      }
    }
    \tl_if_empty:NF \l__leporello_box_store_height_tl {
      \tl_const:co { c_leporello_box_ \int_use:N \g_leporello_box_int _store_height_tl } {
        \l__leporello_box_store_height_tl
      }
      \exp_args:No \tl_if_empty:NF { \l__leporello_box_store_height_tl } {
        \exp_args:No \dim_new:N { \l__leporello_box_store_height_tl }
      }
    }

    \__leporello_box_store:Vn \g_leporello_box_int {#2}
  \group_end:
} { }

\cs_new_protected:Npn \__leporello_box_construct:nnn #1#2#3 {
  \coffin_if_exist:cF { g_leporello_box_ #1 _ #2 _ #3 _outer_coffin } {
    \prop_if_in:cnTF { g_leporello_box_ #3 _prop } { width } {
      \dim_set:Nn \l__leporello_typeset_box_width_dim {
        \prop_item:cn { g_leporello_box_ #3 _prop } { width }
      }
    } {
      \dim_set:Nn \l__leporello_typeset_box_width_dim {
        \clist_item:Nn \l_leporello_columns_clist {#2}
      }
    }

    \coffin_new:c {
      g_leporello_box_ #1 _ #2 _ #3 _inner_coffin
    }
    \vcoffin_gset:cnn {
      g_leporello_box_ #1 _ #2 _ #3 _inner_coffin
    } {
      \l__leporello_typeset_box_width_dim -
        \prop_item:cn { g_leporello_box_ #3 _prop } { padding ~ left } -
        \prop_item:cn { g_leporello_box_ #3 _prop } { padding ~ right }
    } {
      \draw_suspend_begin:
        \int_set:Nn \l_leporello_current_box_int {#3}
        \hook_use:n { leporello / box / before }
          \tl_use:c { g_leporello_box_ #3 _tl }
        \hook_use:n { leporello / box / after }
      \draw_suspend_end:
    }

    \prop_if_in:cnTF { g_leporello_box_ #3 _prop } { height }  {
      \dim_set:Nn \l__leporello_typeset_box_height_dim {
        \prop_item:cn { g_leporello_box_ #3 _prop } { height }
      }
    } {
      \dim_set:Nn \l__leporello_typeset_box_height_dim {
        \coffin_ht:c {
          g_leporello_box_ #1 _ #2 _ #3 _inner_coffin
        } +
        \coffin_dp:c {
          g_leporello_box_ #1 _ #2 _ #3 _inner_coffin
        } +
        \prop_item:cn { g_leporello_box_ #3 _prop } { padding ~ top } +
        \prop_item:cn { g_leporello_box_ #3 _prop } { padding ~ bottom }
      }
    }

    \bool_if:nT { \prop_item:cn { g_leporello_box_ #3 _prop } { stretch ~ height } } {
      \dim_set:Nn \l__leporello_typeset_box_height_dim {
        \fp_to_dim:n {
          \l_leporello_layout_height_dim -
          (
            \clist_item:en {
              \prop_item:cn { g_leporello_box_ #3 _prop } { offset }
            } { 2 }
          )
        }
      }
    }

    \dim_zero:N \l__leporello_typeset_box_bleed_x_dim
    \dim_zero:N \l__leporello_typeset_box_bleed_y_dim

    \int_compare:nNnT {#2} = { 1 } {
      \clist_if_in:enT {
        \prop_item:cn { g_leporello_box_ #3 _prop } { bleed }
      } { l } {
        \dim_add:Nn \l__leporello_typeset_box_bleed_x_dim { \l_leporello_bleed_dim }
      }
    }
    \int_compare:nNnT {#2} = { \l_leporello_column_count_int } {
      \clist_if_in:enT {
        \prop_item:cn { g_leporello_box_ #3 _prop } { bleed }
      } { r } {
        \dim_add:Nn \l__leporello_typeset_box_bleed_x_dim { \l_leporello_bleed_dim }
      }
    }
    \skip_set:Nn \tex_hfuzz:D { \l__leporello_typeset_box_bleed_x_dim } 

    \clist_if_in:enT {
      \prop_item:cn { g_leporello_box_ #3 _prop } { bleed }
    } { t } {
      \dim_add:Nn \l__leporello_typeset_box_bleed_y_dim { \l_leporello_bleed_dim }
    }
    \clist_if_in:enT {
      \prop_item:cn { g_leporello_box_ #3 _prop } { bleed }
    } { b } {
      \dim_add:Nn \l__leporello_typeset_box_bleed_y_dim { \l_leporello_bleed_dim }
    }
    \skip_set:Nn \tex_vfuzz:D { \l__leporello_typeset_box_bleed_y_dim } 

    \coffin_new:c {
      g_leporello_box_ #1 _ #2 _ #3 _outer_coffin
    }
    \vcoffin_gset:cnn {
      g_leporello_box_ #1 _ #2 _ #3 _outer_coffin
    } { \l__leporello_typeset_box_width_dim } {
      \draw_suspend_begin:
      \draw_begin:
        \draw_path_rectangle:nn { 0mm , 0mm } {
          \l__leporello_typeset_box_width_dim +
          \l__leporello_typeset_box_bleed_x_dim ,
          \l__leporello_typeset_box_height_dim +
          \l__leporello_typeset_box_bleed_y_dim
        }
        \str_if_eq:enF {
          \prop_item:cn { g_leporello_box_ #3 _prop } { background ~ color }
        } { none } {
          \group_begin:
            \color_select:e {
              \prop_item:cn { g_leporello_box_ #3 _prop } { background ~ color }
            }
            \draw_path_use:n { fill }
          \group_end:
        }
        \draw_path_use_clear:n { clip }
        \prop_if_in:cnT { g_leporello_box_ #3 _prop } { background ~ code } {
          \exp_args:Ne
          \vbox_set_top:Nn \l__leporello_box_background_box {
            \prop_item:cn { g_leporello_box_ #3 _prop } { background ~ code }
          }
          \draw_box_use:Nn \l__leporello_box_background_box {
            0mm ,
            \l__leporello_typeset_box_height_dim +
            \l__leporello_typeset_box_bleed_y_dim -
            \box_ht:N \l__leporello_box_background_box
          }
        }
      \draw_end:
      \draw_suspend_end:
    }

    \tl_if_exist:cT { c_leporello_box_ #3 _store_width_tl } {
      \exp_args:NNo \exp_args:No
        \dim_set_eq:NN { \use:c { c_leporello_box_ #3 _store_width_tl } }
          \l__leporello_typeset_box_width_dim
    }
    \tl_if_exist:cT { c_leporello_box_ #3 _store_height_tl } {
      \exp_args:NNo \exp_args:No
        \dim_set_eq:NN { \use:c { c_leporello_box_ #3 _store_height_tl } }
          \l__leporello_typeset_box_height_dim
    }
  
    \bool_if:NT \l_leporello_show_id_bool {
      \hcoffin_set:Nn \l__leporello_typeset_mark_coffin {
        \__leporello_id_mark:n { #3 }
      }
      \coffin_attach:cnnNnnnn {
        g_leporello_box_ 
          \int_use:N \l_leporello_current_page_int _
          \int_use:N \l_leporello_current_column_int _
          #3 _inner_coffin
        } { hc } { vc } 
        \l__leporello_typeset_mark_coffin
        { hc } { vc } { 0pt } { 0pt }
    }

    \__leporello_box_set_bleed:n {#3}

    \coffin_attach:cnncnnnn {
      g_leporello_box_ 
        \int_use:N \l_leporello_current_page_int _
        \int_use:N \l_leporello_current_column_int _
        #3 _outer_coffin
    } { l } { t } {
      g_leporello_box_ 
        \int_use:N \l_leporello_current_page_int _
        \int_use:N \l_leporello_current_column_int _
        #3 _inner_coffin
    } { l } { t } {
      \fp_to_dim:n {
        \prop_item:cn { g_leporello_box_ #3 _prop } { padding ~ left } +
        \l__leporello_typeset_box_bleed_left_dim
      }
    } {
      \fp_to_dim:n {
        (
          \prop_item:cn { g_leporello_box_ #3 _prop } { padding ~ top } +
          \l__leporello_typeset_box_bleed_top_dim
        ) * -1
      }
    }
  }
}
\cs_generate_variant:Nn \__leporello_box_construct:nnn { VVn }

\cs_new:Npn \__leporello_box_set_bleed:n #1 {
  \dim_zero:N \l__leporello_typeset_box_bleed_left_dim
  \dim_zero:N \l__leporello_typeset_box_bleed_top_dim

  \int_compare:nNnT {
    \l_leporello_current_column_int
  } = { 1 } {
    \clist_if_in:enT {
      \prop_item:cn { g_leporello_box_ #1 _prop } { bleed }
    } { l } {
      \dim_add:Nn \l__leporello_typeset_box_bleed_left_dim { \l_leporello_bleed_dim }
    }
  }
  \clist_if_in:enT {
    \prop_item:cn { g_leporello_box_ #1 _prop } { bleed }
  } { t } {
    \dim_add:Nn \l__leporello_typeset_box_bleed_top_dim { \l_leporello_bleed_dim }
  }
}

\cs_new_protected:Npn \__leporello_boxes_attach:nn #1#2 {
  \clist_if_in:enTF {
    \prop_item:cn { g_leporello_box_ #2 _prop } { align ~ self }
  } { b } {
    \int_set:Nn \l__leporello_typeset_coffin_attach_align_int { 1 }
    \clist_if_in:enT {
      \prop_item:cn { g_leporello_box_ #2 _prop } { bleed }
    } { b } {
      \dim_add:Nn \l__leporello_typeset_box_bleed_top_dim {
        \l_leporello_bleed_dim
      }
    }
    \clist_if_in:enT {
      \prop_item:cn { g_leporello_box_ #2 _prop } { bleed }
    } { t } {
      \dim_sub:Nn \l__leporello_typeset_box_bleed_top_dim {
        \l_leporello_bleed_dim
      }
    } 
  } {
    \int_set:Nn \l__leporello_typeset_coffin_attach_align_int { -1 }
  }

  \prop_if_exist:cT { g_leporello_box_ #1 _prop } {
    \clist_if_in:enT {
      \prop_item:cn { g_leporello_box_ #2 _prop } { align ~ parent }
    } { l } {
      \clist_if_in:enT {
        \prop_item:cn { g_leporello_box_ #1 _prop } { bleed }
      } { l } {
        \dim_sub:Nn \l__leporello_typeset_box_bleed_left_dim {
          \l_leporello_bleed_dim
        }
      }
    }
    \clist_if_in:enT {
      \prop_item:cn { g_leporello_box_ #2 _prop } { align ~ parent }
    } { r } {
      \clist_if_in:enT {
        \prop_item:cn { g_leporello_box_ #1 _prop } { bleed }
      } { r } {
        \dim_sub:Nn \l__leporello_typeset_box_bleed_left_dim {
          \l_leporello_bleed_dim
        }
      }
    }
    \clist_if_in:enT {
      \prop_item:cn { g_leporello_box_ #2 _prop } { align ~ parent }
    } { t } {
      \clist_if_in:enT {
        \prop_item:cn { g_leporello_box_ #1 _prop } { bleed }
      } { t } {
        \dim_add:Nn \l__leporello_typeset_box_bleed_top_dim {
          \l_leporello_bleed_dim
        }
      }
    }
    \clist_if_in:enT {
      \prop_item:cn { g_leporello_box_ #2 _prop } { align ~ parent }
    } { b } {
      \clist_if_in:enT {
        \prop_item:cn { g_leporello_box_ #1 _prop } { bleed }
      } { b } {
        \dim_add:Nn \l__leporello_typeset_box_bleed_top_dim {
          \l_leporello_bleed_dim
        }
      }
    }
  }

  \coffin_attach:ceeceeee {
    \int_compare:nNnTF {#1} = { 0 } {
      l_leporello_current_column_coffin
    } {
      g_leporello_box_ 
        \int_use:N \l_leporello_current_page_int _
        \int_use:N \l_leporello_current_column_int _
        #1 _outer_coffin
    }
  } {
    \clist_item:en {
      \prop_item:cn { g_leporello_box_ #2 _prop } { align ~ parent }
    } { 1 }
  } {
    \clist_item:en {
      \prop_item:cn { g_leporello_box_ #2 _prop } { align ~ parent }
    } { 2 }
  } {
    g_leporello_box_ 
      \int_use:N \l_leporello_current_page_int _
      \int_use:N \l_leporello_current_column_int _
      #2 _outer_coffin
  } {
    \clist_item:en {
      \prop_item:cn { g_leporello_box_ #2 _prop } { align ~ self }
    } { 1 }
  } {
    \clist_item:en {
      \prop_item:cn { g_leporello_box_ #2 _prop } { align ~ self }
    } { 2 }
  } {
    \fp_to_dim:n {
      \clist_item:en {
        \prop_item:cn { g_leporello_box_ #2 _prop } { offset }
      } { 1 } -
      \l__leporello_typeset_box_bleed_left_dim
    }
  } {
    \fp_to_dim:n {
      (
        \clist_item:en {
          \prop_item:cn { g_leporello_box_ #2 _prop } { offset }
        } { 2 } -
        \l__leporello_typeset_box_bleed_top_dim
      ) * \l__leporello_typeset_coffin_attach_align_int
    }
  }
}

\cs_new_protected:Npn \__leporello_box_attach_children:n #1 {
  \clist_if_exist:cT { g_leporello_box_ #1 _children_clist } {
    \clist_map_inline:cn { g_leporello_box_ #1 _children_clist } {
      \__leporello_box_construct:VVn
        \l_leporello_current_page_int
        \l_leporello_current_column_int
        {##1}
      \__leporello_box_attach_children:n {##1}
    }
    \clist_map_inline:cn { g_leporello_box_ #1 _children_clist } {
      \__leporello_box_set_bleed:n {##1}
      \__leporello_boxes_attach:nn {#1} {##1}
    }
  }
}

\NewDocumentCommand { \leporellotypesetcolumns } { O{} m } {
  \int_incr:N \l_leporello_current_page_int

  \int_compare:nNnT { \clist_count:n {#2} } > {
    \l_leporello_column_count_int
  } {
    \msg_error:nneV { leporello } { too-many-columns }
      { \clist_count:n {#2} } \l_leporello_column_count_int
  }

  \group_begin:
    \keys_set:nn { leporello / print } {#1}
    \bool_if:NT \l_leporello_reverse_layout_bool {
      \clist_reverse:N \l_leporello_columns_clist
    }

    \int_zero:N \l_leporello_current_column_int
    \dim_zero:N \l_leporello_current_column_offset_dim
    \leporello_draw_absolute:nn { 0mm , 0mm } {
      \clist_map_inline:nn {#2} {
        \int_incr:N \l_leporello_current_column_int

        \tl_if_exist:cF { g_leporello_column_ ##1 _tl } {
          \msg_error:nnn { leporello } { column-undefined } {##1}
        }

        \vcoffin_set:Nnn \l_leporello_current_column_coffin {
          \clist_item:NV \l_leporello_columns_clist
            \l_leporello_current_column_int
        } {
          \draw_suspend_begin:
          \draw_begin:
            \draw_path_rectangle:nn { 0mm , 0mm } {
              \clist_item:NV \l_leporello_columns_clist
                \l_leporello_current_column_int ,
              \l_leporello_layout_height_dim
            }
            \draw_path_use_clear:n { clip }
            \vbox_set_top:Nn \l__leporello_typeset_column_box {
              \draw_suspend_begin:
                \str_set:Nn \l_leporello_current_column_str {##1}
                \hook_use:n { leporello / column / before }
                  \tl_use:c { g_leporello_column_ ##1 _tl }
                \hook_use:n { leporello / column / after }
              \draw_suspend_end:
            }
            \draw_box_use:N \l__leporello_typeset_column_box
          \draw_end:
          \draw_suspend_end:
        }

        \clist_map_inline:cn { g_leporello_column_ ##1 _boxes_clist } {
          \__leporello_box_construct:VVn
            \l_leporello_current_page_int
            \l_leporello_current_column_int
            {####1}
          \iow_log:n {####1}
          \__leporello_box_attach_children:n {####1}
        }
        \clist_map_inline:cn { g_leporello_column_ ##1 _boxes_clist } {
          \clist_if_in:NnF \g_leporello_parent_boxes_clist {####1} {
            \__leporello_box_set_bleed:n {####1}
            \__leporello_boxes_attach:nn { 0 } {####1}
          }
        }

        \draw_coffin_use:Nnnn \l_leporello_current_column_coffin
          { l } { t } { \l_leporello_current_column_offset_dim , 0mm }

        \dim_add:Nn \l_leporello_current_column_offset_dim {
          \clist_item:NV \l_leporello_columns_clist
            \l_leporello_current_column_int
        }
      }

      \bool_if:NT \l_leporello_show_frames_bool {
        \int_zero:N \l_leporello_current_column_int
        \dim_zero:N \l_leporello_current_column_offset_dim
        \clist_map_inline:Nn \l_leporello_columns_clist {
          \int_incr:N \l_leporello_current_column_int
          \draw_path_rectangle:nn {
            \l_leporello_current_column_offset_dim , 0mm
          } {
            ##1 ,
            - \l_leporello_layout_height_dim
          }
          \draw_path_use_clear:n { stroke }
          \dim_add:Nn \l_leporello_current_column_offset_dim {
            ##1
          }
        }
      }
    }
  \group_end:
}

% === Flow mechanism

\int_new:N \l_leporello_box_flow_into_int
\box_new:N \g_leporello_box_flow_temp_box
\seq_new:N \g_leporello_box_flow_temp_seq
\dim_new:N \l_leporello_box_flow_width_first_dim
\dim_new:N \l_leporello_box_flow_width_second_dim

\keys_define:nn { leporello / box } {
  flow ~ into        .code:n = {
    \prop_gput:cne { g_leporello_box_ \int_use:N \g_leporello_box_int _prop } 
      { flow ~ into } {#1}
  }
}

\hook_gput_code:nnn { leporello / box / before } { . } {
  \prop_if_in:cnT { g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop } 
    { flow ~ into } {
    \int_set:Nn \l_leporello_box_flow_into_int {
      \prop_item:cn { g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop } 
        { flow ~ into }
    }

    \box_new:c {
      g_leporello_box_flow_ \int_use:N \l_leporello_box_flow_into_int _box
    }
    \tl_if_exist:cF { g_leporello_box_ \int_use:N \l_leporello_box_flow_into_int _tl } {
      \tl_new:c { g_leporello_box_ \int_use:N \l_leporello_box_flow_into_int _tl }
    }
        
    \tl_if_in:cnTF { g_leporello_box_ \int_use:N \l_leporello_current_box_int _tl } {
      \leporelloboxbreak
    } {
      \seq_gset_split:Nne \g_leporello_box_flow_temp_seq {
        \leporelloboxbreak                
      } {
        \tl_use:c { g_leporello_box_ \int_use:N \l_leporello_current_box_int _tl }
      }
      \tl_clear:c { g_leporello_box_ \int_use:N \l_leporello_current_box_int _tl }
      \vbox_gset_top:Nn \g_leporello_box_flow_temp_box {
        \prop_item:cn { g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop } 
          { pre }
        \seq_item:Nn \g_leporello_box_flow_temp_seq { 1 }
        \group_begin:
          \skip_zero:N \tex_parfillskip:D
          \tex_par:D
        \group_end:
      }
      \tl_gput_left:ce { g_leporello_box_ \int_use:N \l_leporello_box_flow_into_int _tl } {
        \prop_item:cn { g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop } 
          { pre }
        \tex_noindent:D
        \seq_item:Nn \g_leporello_box_flow_temp_seq { 2 }
        \tex_par:D
      }
    } {
      \vbox_gset_top:cn {
        g_leporello_box_flow_ \int_use:N \l_leporello_box_flow_into_int _box
      } {
        \tl_use:c { g_leporello_box_ \int_use:N \l_leporello_current_box_int _tl }
      }
      \tl_clear:c { g_leporello_box_ \int_use:N \l_leporello_current_box_int _tl }
      \group_begin:
        \skip_zero:N \tex_splittopskip:D
        \vbox_gset_split_to_ht:Ncn \g_leporello_box_flow_temp_box {
          g_leporello_box_flow_ \int_use:N \l_leporello_box_flow_into_int _box
        } { 
          \prop_if_in:cnTF { 
            g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop
          } { height } {
            \prop_item:cn {
              g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop
            } { height }
          } {
            \l_leporello_layout_height_dim
          } -
          \prop_item:cn {
             g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop
          } { padding ~ top } -
          \prop_item:cn {
            g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop
          } { padding ~ bottom }
        }
      \group_end:
      \tl_gput_left:ce { g_leporello_box_ \int_use:N \l_leporello_box_flow_into_int _tl } {
        \exp_not:N \box_use_drop:c {
          g_leporello_box_flow_ \int_use:N \l_leporello_box_flow_into_int _box
        }
      }
    }
    \vbox_top:n {
      \vbox_unpack_drop:N \g_leporello_box_flow_temp_box
    }
  }
}

\NewDocumentCommand { \leporelloboxbreak } { } {
  \tex_relax:D
}

\NewDocumentCommand { \leporellojustified } { } {
  \skip_zero:N \tex_rightskip:D
  \skip_zero:N \tex_leftskip:D
}

% EOF
