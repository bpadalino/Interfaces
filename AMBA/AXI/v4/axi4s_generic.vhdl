library ieee ;
use     ieee.std_logic_1164.all ;

package axi4s_generic is
  generic (
    DATA_BYTES  :   positive    := 4 ;
    DEST_WIDTH  :   natural     := 0 ;
    ID_WIDTH    :   natural     := 0 ;
    USER_WIDTH  :   natural     := 0 ;
  ) ;

    subtype DATA_RANGE is natural range DATA_BYTES*8-1 downto 0 ;
    subtype DEST_RANGE is natural range DEST_WIDTH-1 downto 0 ;
    subtype ID_RANGE is natural range ID_WIDTH-1 downto 0 ;
    subtype KEEP_RANGE is natural range DATA_BYTES-1 downto 0 ;
    subtype USER_RANGE is natural range USER_WIDTH-1 downto 0 ;

    type axis_t is record
        data    :   std_ulogic_vector(DATA_RANGE) ;
        dest    :   std_ulogic_vector(DEST_RANGE) ;
        id      :   std_ulogic_vector(ID_RANGE) ;
        keep    :   std_ulogic_vector(KEEP_RANGE) ;
        strb    :   std_ulogic_vector(KEEP_RANGE) ;
        user    :   std_ulogic_vector(USER_RANGE) ;
        last    :   std_ulogic ;
        valid   :   std_ulogic ;
        ready   :   std_ulogic ;
    end record ;

    view master of axis_t is
        data    :   out ;
        dest    :   out ;
        id      :   out ;
        keep    :   out ;
        strb    :   out ;
        user    :   out ;
        last    :   out ;
        valid   :   out ;
        ready   :   in ;
    end view ;

    alias slave is master'converse ;

end package ;
