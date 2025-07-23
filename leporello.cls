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
  {2025/07/23} {0.3} {Document class for typesetting folding flyers}

\cs_generate_variant:Nn \clist_item:Nn { NV }
\cs_generate_variant:Nn \color_select:n { e }
\cs_generate_variant:Nn \coffin_attach:NnnNnnnn { Neeceeee }
\cs_generate_variant:Nn \prop_gput:Nnn { cnV , cne }
\cs_generate_variant:Nn \tl_const:Nn { co }
\cs_generate_variant:Nn \msg_error:nnnn { nneV }

\prg_generate_conditional_variant:Nnn \clist_if_in:nn { en } { T , TF }
\prg_generate_conditional_variant:Nnn \str_if_eq:nn { en } { F }

\bool_new:N \l_leporello_prepress_bool
\bool_new:N \l_leporello_show_frames_bool
\dim_new:N \l_leporello_layout_height_dim
\dim_new:N \l_leporello_bleed_dim
\dim_new:N \l_leporello_info_area_dim
\clist_new:N \l_leporello_columns_clist
\int_new:N \l_leporello_column_count_int

\dim_new:N \l__leporello_layout_width_dim
\dim_new:N \l__leporello_paper_height_dim
\dim_new:N \l__leporello_paper_width_dim

\keys_define:nn { leporello / global } {
  columns         .code:n     = {
    \clist_set:Nn \l_leporello_columns_clist {#1}
    \int_set:Nn \l_leporello_column_count_int {
      \clist_count:N \l_leporello_columns_clist
    }
    \dim_zero:N \l__leporello_layout_width_dim
    \clist_map_inline:Nn \l_leporello_columns_clist {
      \dim_add:Nn \l__leporello_layout_width_dim {##1}
    }
  } ,
  columns         .initial:n  = { 97mm , 100mm , 100mm } ,
  layout ~ height .dim_set:N  = \l_leporello_layout_height_dim ,
  layout ~ height .initial:n  = { 210mm } ,
  show ~ frames   .bool_set:N = \l_leporello_show_frames_bool ,
  show ~ frames   .default:n  = { true } ,
  show ~ frames   .initial:n  = { false } ,
  prepress        .bool_set:N = \l_leporello_prepress_bool ,
  prepress        .default:n  = { true } ,
  prepress        .initial:n  = { false } ,
  bleed           .dim_set:N  = \l_leporello_bleed_dim ,
  bleed           .initial:n  = { 3mm } ,
  info ~ area     .dim_set:N  = \l_leporello_info_area_dim ,
  info ~ area     .initial:n  = { 10mm } ,

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

\msg_new:nnn { leporello } { column-undefined } {
  \msg_error_text:n { leporello } \iow_newline:
  Column ~ #1 ~ undefined.
}

\int_new:N \l_leporello_current_page_int
\int_new:N \l_leporello_current_column_int
\str_new:N \l_leporello_current_column_str
\dim_new:N \l_leporello_current_column_offset_dim
\coffin_new:N \l_leporello_current_column_coffin
\coffin_new:N \l_leporello_current_column_phantom_coffin

\int_new:N \g_leporello_box_int
\int_new:N \l_leporello_current_box_int

\tl_new:N \l__leporello_box_align_parent_clist
\tl_new:N \l__leporello_box_align_self_clist
\tl_new:N \l__leporello_box_offset_clist
\dim_new:N \l__leporello_box_width_dim
\dim_new:N \l__leporello_box_height_dim
\tl_new:N \l__leporello_box_store_width_tl
\tl_new:N \l__leporello_box_store_height_tl
\bool_new:N \l__leporello_box_height_bool
\dim_new:N \l__leporello_box_padding_top_dim
\dim_new:N \l__leporello_box_padding_bottom_dim
\dim_new:N \l__leporello_box_padding_left_dim
\dim_new:N \l__leporello_box_padding_right_dim
\tl_new:N \l__leporello_box_background_tl
\clist_new:N \l__leporello_box_bleed_clist

\dim_new:N \l__leporello_typeset_box_width_dim
\dim_new:N \l__leporello_typeset_box_height_dim
\dim_new:N \l__leporello_typeset_box_bleed_top_dim
\dim_new:N \l__leporello_typeset_box_bleed_left_dim
\dim_new:N \l__leporello_typeset_box_bleed_y_dim
\dim_new:N \l__leporello_typeset_box_bleed_x_dim
\int_new:N \l__leporello_typeset_coffin_attach_align_int

\keys_define:nn { leporello / box } {
  align ~ parent   .clist_set:N = \l__leporello_box_align_parent_clist ,
  align ~ parent   .initial:n   = { l , t } ,
  align ~ self     .clist_set:N = \l__leporello_box_align_self_clist ,
  align ~ self     .initial:n   = { l , t } ,
  offset           .clist_set:N = \l__leporello_box_offset_clist ,
  offset           .initial:n   = { 0mm , 0mm } ,
  width            .dim_set:N   = \l__leporello_box_width_dim ,
  width            .initial:n   = { 0mm } ,
  height           .dim_set:N   = \l__leporello_box_height_dim ,
  height           .initial:n   = { 0mm } ,
  stretch ~ height .bool_set:N  = \l__leporello_box_stretch_height_bool ,
  stretch ~ height .default:n   = { true } ,
  stretch ~ height .initial:n   = { false } ,
  padding / top    .dim_set:N   = \l__leporello_box_padding_top_dim ,
  padding / bottom .dim_set:N   = \l__leporello_box_padding_bottom_dim ,
  padding / left   .dim_set:N   = \l__leporello_box_padding_left_dim ,
  padding / right  .dim_set:N   = \l__leporello_box_padding_right_dim ,
  padding          .code:n      = { \keys_set:nn { leporello / box / padding } {#1} } ,
  padding          .initial:n   = {
    top    = 7.5mm ,
    bottom = 7.5mm ,
    left   = 7.5mm ,
    right  = 7.5mm
  } ,
  no ~ padding     .meta:n      = {
    padding = {
      top    = 0mm ,
      bottom = 0mm ,
      left   = 0mm ,
      right  = 0mm
    }
  } ,
  background       .tl_set:N    = \l__leporello_box_background_tl ,
  background       .initial:n   = { none } ,
  bleed            .clist_set:N = \l__leporello_box_bleed_clist ,
  store ~ width    .tl_set:N    = \l__leporello_box_store_width_tl ,
  store ~ height   .tl_set:N    = \l__leporello_box_store_height_tl
}

\bool_new:N \l_leporello_reverse_layout_bool

\keys_define:nn { leporello / print } {
  reverse ~ layout .bool_set:N = \l_leporello_reverse_layout_bool ,
  reverse ~ layout .default:n  = { true } ,
  reverse ~ layout .initial:n  = { false } ,
}

\bool_new:N \l_leporello_image_fill_bleed_bool
\dim_new:N \l_leporello_image_clip_width_dim
\dim_new:N \l_leporello_image_clip_height_dim
\dim_new:N \l_leporello_image_offset_x_dim
\dim_new:N \l_leporello_image_offset_y_dim
\dim_new:N \l_leporello_image_outer_offset_x_dim
\dim_new:N \l_leporello_image_outer_offset_y_dim
\fp_new:N \l_leporello_image_scale_fp
\box_new:N \l__leporello_image_original_box

\keys_define:nn { leporello / image } {
  fill ~ bleed     .bool_set:N  = \l_leporello_image_fill_bleed_bool ,
  fill ~ bleed     .default:n   = { true } ,
  fill ~ bleed     .initial:n   = { false } ,
  clip ~ width     .dim_set:N   = \l_leporello_image_clip_width_dim ,
  clip ~ height    .dim_set:N   = \l_leporello_image_clip_height_dim ,
  offset           .code:n      = {
    \dim_set:Nn \l_leporello_image_offset_x_dim { \clist_item:nn {#1} { 1 } }
    \dim_set:Nn \l_leporello_image_offset_y_dim { - \clist_item:nn {#1} { 2 } }
  } ,
  offset           .initial:n   = { 0mm , 0mm } ,
  scale            .fp_set:N    = \l_leporello_image_scale_fp ,
  scale            .initial:n   = { 1 }
}

% ===

\ProcessKeyOptions [ leporello / global ]
\LoadClass { article }
\RequirePackage { geometry }
\RequirePackage { l3draw }

\cs_new_protected:Npn \leporello_draw_absolute:nn #1#2 {
  \AddToHookNext { shipout / background } {
    \draw_begin:
      \bool_set_false:N \l_draw_bb_update_bool
      \draw_transform_shift:n {#1}
      #2
    \draw_end:
  }
  \null
  \clearpage
}

\cs_if_exist:NF \draw_set_linewidth:n {
  \cs_set_eq:NN \draw_set_linewidth:n \draw_linewidth:n
}

\cs_new_protected:Npn \__leporello_cropmarks: {
  \draw_begin:
    \bool_set_false:N \l_draw_bb_update_bool
    \draw_set_linewidth:n { .25pt }
    \draw_scope_begin:
      \draw_transform_shift:n {
        10mm , -10mm
      }
      \draw_path_moveto:n { -5pt , 0pt }
      \draw_path_lineto:n { -20pt , 0pt }
      \draw_path_use:n { stroke }
    \draw_scope_end:
    \draw_scope_begin:
      \draw_transform_shift:n {
        10mm , 10mm - \paperheight
      }
      \draw_path_moveto:n { -5pt , 0pt }
      \draw_path_lineto:n { -20pt , 0pt }
      \draw_path_use:n { stroke }
    \draw_scope_end:
    \draw_scope_begin:
      \draw_transform_shift:n {
        \paperwidth - 10mm , -10mm
      }
      \draw_path_moveto:n { 5pt , 0pt }
      \draw_path_lineto:n { 20pt , 0pt }
      \draw_path_use:n { stroke }
    \draw_scope_end:
    \draw_scope_begin:
      \draw_transform_shift:n {
        \paperwidth - 10mm , 10mm - \paperheight
      }
      \draw_path_moveto:n { 5pt , 0pt }
      \draw_path_lineto:n { 20pt , 0pt }
      \draw_path_use:n { stroke }
    \draw_scope_end:
  \draw_end:
}
\cs_new_protected:Npn \__leporello_cropmark_n:n #1 {
  \draw_begin:
    \bool_set_false:N \l_draw_bb_update_bool
    \draw_set_linewidth:n { .25pt }
    \draw_transform_shift:n {
      #1 , -10mm
    }
    \draw_path_moveto:n { 0pt , 5pt }
    \draw_path_lineto:n { 0pt , 20pt }
    \draw_path_use:n { stroke }
  \draw_end:
}
\cs_new_protected:Npn \__leporello_cropmark_s:n #1 {
  \draw_begin:
    \bool_set_false:N \l_draw_bb_update_bool
    \draw_set_linewidth:n { .25pt }
    \draw_transform_shift:n {
      #1 , 10mm - \paperheight
    }
    \draw_path_moveto:n { 0pt , -5pt }
    \draw_path_lineto:n { 0pt , -20pt }
    \draw_path_use:n { stroke }
  \draw_end:
}

\AddToHook { begindocument / before } {
  \pagestyle { empty }
  \dim_set:Nn \l__leporello_paper_height_dim {
    \l_leporello_layout_height_dim + 2 \l_leporello_info_area_dim
  }
  \dim_set:Nn \l__leporello_paper_width_dim {
    \l__leporello_layout_width_dim + 2 \l_leporello_info_area_dim
  }
  \bool_if:NTF \l_leporello_prepress_bool {
    \geometry {
      layoutwidth = \l__leporello_layout_width_dim ,
      layoutheight = \l_leporello_layout_height_dim ,
      layouthoffset = \l_leporello_info_area_dim ,
      layoutvoffset = \l_leporello_info_area_dim ,
      paperwidth = \l__leporello_paper_width_dim ,
      paperheight = \l__leporello_paper_height_dim ,
      margin = 0pt
    }
    \AddToHook { shipout / foreground } {
      \__leporello_cropmarks:
      \dim_set:Nn \l_leporello_current_column_offset_dim {
        \l_leporello_info_area_dim
      }
      \__leporello_cropmark_n:n { \l_leporello_current_column_offset_dim }
      \__leporello_cropmark_s:n { \l_leporello_current_column_offset_dim }
      \clist_map_inline:Nn \l_leporello_columns_clist {
        \dim_add:Nn \l_leporello_current_column_offset_dim {
          #1
        }
        \__leporello_cropmark_n:n { \l_leporello_current_column_offset_dim }
        \__leporello_cropmark_s:n { \l_leporello_current_column_offset_dim }
      }
    }
  } {
    \geometry {
      paperwidth = \l__leporello_layout_width_dim ,
      paperheight = \l_leporello_layout_height_dim ,
      margin = 0pt
    }
  }
}

\NewDocumentCommand { \leporelloset } { m } {
  \keys_set:nn { leporello / global } {#1}
}

\NewDocumentCommand { \leporellosetstyle } { m m } {
  \keys_define:nn { leporello / box } {
    #1  .meta:n = {#2}
  }
}

\NewDocumentCommand { \leporellocolordefine } { m m m } {
  \color_set:nnn {#1} {#2} {#3}
}

\NewDocumentCommand { \leporellocolorselect } { m } {
  \color_select:n {#1}
}

\clist_new:N \l__leporello_graphicx_options_clist
\NewDocumentCommand { \leporelloimage } { O{} m } {
  \keys_set:nn { leporello / image } {#1}

  \hbox_set:Nn \l__leporello_image_original_box {
    \includegraphics {#2}
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
        \dim_add:Nn \l_leporello_image_outer_offset_x_dim { \l_leporello_bleed_dim }
        \dim_add:Nn \l_leporello_image_clip_width_dim { \l_leporello_bleed_dim }
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
        \dim_add:Nn \l_leporello_image_clip_width_dim { \l_leporello_bleed_dim }
      }
    }
    \clist_if_in:enT {
      \prop_item:cn {
        g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop
      } { bleed }
    } { t } {
      \dim_add:Nn \l_leporello_image_outer_offset_y_dim { \l_leporello_bleed_dim }
      \dim_add:Nn \l_leporello_image_clip_height_dim { \l_leporello_bleed_dim }
    }
    \clist_if_in:enT {
      \prop_item:cn {
        g_leporello_box_ \int_use:N \l_leporello_current_box_int _prop
      } { bleed }
    } { b } {
      \dim_add:Nn \l_leporello_image_clip_height_dim { \l_leporello_bleed_dim }
    }
  }

  \dim_add:Nn \l_leporello_image_offset_y_dim {
    \box_ht:N \l__leporello_image_original_box -
    \l_leporello_image_clip_height_dim
  }

  \skip_vertical:n { - \l_leporello_image_outer_offset_y_dim }
  \skip_horizontal:n { - \l_leporello_image_outer_offset_x_dim }
  \includegraphics [
    scale = \fp_use:N \l_leporello_image_scale_fp ,
    clip ,
    viewport =
      \dim_to_decimal_in_bp:n {
        \fp_to_dim:n {
          \l_leporello_image_offset_x_dim / \l_leporello_image_scale_fp
        }
      } ~
      \dim_to_decimal_in_bp:n {
        \fp_to_dim:n {
          \l_leporello_image_offset_y_dim / \l_leporello_image_scale_fp
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
      } ,
  ] {#2}
}

\NewDocumentEnvironment { leporellocolumn } { m +b } {
  \clist_new:c { g_leporello_column_ #1 _boxes_clist }
  \tl_const:cn { c_leporello_column_ #1 _tl } {
    \str_set:Nn \l_leporello_current_column_str {#1}
    #2
  }
} { }

\NewDocumentEnvironment { leporellobox } { O{} +b } {
  \int_gincr:N \g_leporello_box_int

  \str_if_empty:NT \l_leporello_current_column_str {
    \msg_error:nnV { leporello } { box-outside-column }
      \g_leporello_box_int
  }

  \clist_gput_right:cV {
    g_leporello_column_ \str_use:N \l_leporello_current_column_str _boxes_clist
  } \g_leporello_box_int

  \keys_set:nn { leporello / box } {#1}
  \prop_new:c { g_leporello_box_ \int_use:N \g_leporello_box_int _prop }
  \prop_gput:cne { g_leporello_box_ \int_use:N \g_leporello_box_int _prop } { align ~ parent }
    { \clist_use:Nn \l__leporello_box_align_parent_clist { , } }
  \prop_gput:cne { g_leporello_box_ \int_use:N \g_leporello_box_int _prop } { align ~ self }
    { \clist_use:Nn \l__leporello_box_align_self_clist { , } }
  \prop_gput:cne { g_leporello_box_ \int_use:N \g_leporello_box_int _prop } { offset }
    { \clist_use:Nn \l__leporello_box_offset_clist { , } }
  \prop_gput:cnV { g_leporello_box_ \int_use:N \g_leporello_box_int _prop } { width }
    \l__leporello_box_width_dim
  \prop_gput:cnV { g_leporello_box_ \int_use:N \g_leporello_box_int _prop } { height }
    \l__leporello_box_height_dim
  \prop_gput:cne { g_leporello_box_ \int_use:N \g_leporello_box_int _prop } { stretch ~ height }
    { \bool_if_p:N \l__leporello_box_stretch_height_bool }
  \prop_gput:cnV { g_leporello_box_ \int_use:N \g_leporello_box_int _prop } { padding ~ top }
    \l__leporello_box_padding_top_dim
  \prop_gput:cnV { g_leporello_box_ \int_use:N \g_leporello_box_int _prop } { padding ~ bottom }
    \l__leporello_box_padding_bottom_dim
  \prop_gput:cnV { g_leporello_box_ \int_use:N \g_leporello_box_int _prop } { padding ~ left }
    \l__leporello_box_padding_left_dim
  \prop_gput:cnV { g_leporello_box_ \int_use:N \g_leporello_box_int _prop } { padding ~ right }
    \l__leporello_box_padding_right_dim
  \prop_gput:cnV { g_leporello_box_ \int_use:N \g_leporello_box_int _prop } { background }
    \l__leporello_box_background_tl
  \prop_gput:cne { g_leporello_box_ \int_use:N \g_leporello_box_int _prop } { bleed }
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

  \tl_const:cn { c_leporello_box_ \int_use:N \g_leporello_box_int _tl } {
    \int_set_eq:NN \l_leporello_current_box_int \g_leporello_box_int
    #2
  }
} { }

\cs_new:Npn \__leporello_box_construct:nnn #1#2#3 {
  \dim_compare:nNnTF {
    \prop_item:cn { g_leporello_box_ #3 _prop } { width }
  } = { 0mm } {
    \dim_set:Nn \l__leporello_typeset_box_width_dim {
      \clist_item:Nn \l_leporello_columns_clist {#2}
    }
  } {
    \dim_set:Nn \l__leporello_typeset_box_width_dim {
      \prop_item:cn { g_leporello_box_ #3 _prop } { width }
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
      \tl_use:c { c_leporello_box_ #3 _tl }
    \draw_suspend_end:
  }

  \dim_compare:nNnTF {
    \prop_item:cn { g_leporello_box_ #3 _prop } { height }
  } = { 0mm } {
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
  } {
    \dim_set:Nn \l__leporello_typeset_box_height_dim {
      \prop_item:cn { g_leporello_box_ #3 _prop } { height }
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
          \prop_item:cn { g_leporello_box_ #3 _prop } { background }
        } { none } {
          \color_select:e {
            \prop_item:cn { g_leporello_box_ #3 _prop } { background }
          }
          \draw_path_use_clear:n { fill }
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
}
\cs_generate_variant:Nn \__leporello_box_construct:nnn { VVn }

\NewDocumentCommand { \printleporellocolumns } { O{} m } {
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
    \leporello_draw_absolute:nn {
      \bool_if:NTF \l_leporello_prepress_bool {
        \l_leporello_info_area_dim , -\l_leporello_info_area_dim
      } {
        0mm , 0mm
      }
    } {
      \clist_map_inline:nn {#2} {
        \int_incr:N \l_leporello_current_column_int

        \tl_if_exist:cF { c_leporello_column_ ##1 _tl } {
          \msg_error:nnn { leporello } { column-undefined } {##1}
        }

        \vcoffin_set:Nnn \l_leporello_current_column_coffin {
          \clist_item:NV \l_leporello_columns_clist
            \l_leporello_current_column_int
        } {
          \draw_suspend_begin:
            \tl_use:c { c_leporello_column_ ##1 _tl }
          \draw_suspend_end:
        }
        \vcoffin_set:Nnn \l_leporello_current_column_phantom_coffin {
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
          \draw_end:
          \draw_suspend_end:
        }

        \clist_map_inline:cn { g_leporello_column_ ##1 _boxes_clist } {
          \__leporello_box_construct:VVn
            \l_leporello_current_page_int
            \l_leporello_current_column_int
            {####1}

          \dim_zero:N \l__leporello_typeset_box_bleed_top_dim
          \dim_zero:N \l__leporello_typeset_box_bleed_left_dim

          \clist_if_in:enT {
            \prop_item:cn { g_leporello_box_ ####1 _prop } { bleed }
          } { t } {
            \dim_add:Nn \l__leporello_typeset_box_bleed_top_dim { \l_leporello_bleed_dim }
          }
          \int_compare:nNnT {
            \l_leporello_current_column_int
          } = { 1 } {
            \clist_if_in:enT {
              \prop_item:cn { g_leporello_box_ ####1 _prop } { bleed }
            } { l } {
              \dim_add:Nn \l__leporello_typeset_box_bleed_left_dim { \l_leporello_bleed_dim }
            }
          }

          \coffin_attach:cnncnnnn {
            g_leporello_box_ 
              \int_use:N \l_leporello_current_page_int _
              \int_use:N \l_leporello_current_column_int _
              ####1 _outer_coffin
          } { l } { t } {
            g_leporello_box_ 
              \int_use:N \l_leporello_current_page_int _
              \int_use:N \l_leporello_current_column_int _
              ####1 _inner_coffin
          } { l } { t } {
            \fp_to_dim:n {
              \prop_item:cn { g_leporello_box_ ####1 _prop } { padding ~ left } +
              \l__leporello_typeset_box_bleed_left_dim
            }
          } {
            \fp_to_dim:n {
              (
                \prop_item:cn { g_leporello_box_ ####1 _prop } { padding ~ top } +
                \l__leporello_typeset_box_bleed_top_dim
              ) * -1
            }
          }

          \clist_if_in:enTF {
            \prop_item:cn { g_leporello_box_ ####1 _prop } { align ~ self }
          } { b } { 
            \int_set:Nn \l__leporello_typeset_coffin_attach_align_int { 1 }
          } {
            \int_set:Nn \l__leporello_typeset_coffin_attach_align_int { -1 }
          }

          \coffin_attach:Neeceeee \l_leporello_current_column_phantom_coffin {
            \clist_item:en {
              \prop_item:cn { g_leporello_box_ ####1 _prop } { align ~ parent }
            } { 1 }
          } {
            \clist_item:en {
              \prop_item:cn { g_leporello_box_ ####1 _prop } { align ~ parent }
            } { 2 }
          } {
            g_leporello_box_ 
              \int_use:N \l_leporello_current_page_int _
              \int_use:N \l_leporello_current_column_int _
              ####1 _outer_coffin
          } {
            \clist_item:en {
              \prop_item:cn { g_leporello_box_ ####1 _prop } { align ~ self }
            } { 1 }
          } {
            \clist_item:en {
              \prop_item:cn { g_leporello_box_ ####1 _prop } { align ~ self }
            } { 2 }
          } {
            \fp_to_dim:n {
              \clist_item:en {
                \prop_item:cn { g_leporello_box_ ####1 _prop } { offset }
              } { 1 } -
              \l__leporello_typeset_box_bleed_left_dim
            }
          } {
            \fp_to_dim:n {
              (
                \clist_item:en {
                  \prop_item:cn { g_leporello_box_ ####1 _prop } { offset }
                } { 2 } -
                \l__leporello_typeset_box_bleed_top_dim
              ) * \l__leporello_typeset_coffin_attach_align_int
            }
          }
        }

        \draw_coffin_use:Nnnn \l_leporello_current_column_phantom_coffin
          { l } { t } { \l_leporello_current_column_offset_dim , 0mm }
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
} { }

% EOF
