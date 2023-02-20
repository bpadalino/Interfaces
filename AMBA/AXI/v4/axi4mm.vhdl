use work.axi4mm_common.all ;

package axi4mm is

    type axi4mm_t is record
        aw  :   address_t ;
        b   :   bresp_t ;
        w   :   wdata_t ;
        ar  :   address_t ;
        r   :   rdata_t ;
    end record ;

    type axi4mm_array_t is array(natural range <>) of axi4mm_t ;

    view master of axi4mm_t is
        aw  :   view address_master ;
        ar  :   view address_master ;
        b   :   view bresp_master ;
        w   :   view wdata_master ;
        r   :   view rdata_master ;
    end view ;

    alias slave is master'converse ;

end package ;
