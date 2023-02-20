library ieee ;
    use ieee.std_logic_1164.all ;

package axi4s is

    type axis_t is record
        data    :   std_ulogic_vector ;
        dest    :   std_ulogic_vector ;
        id      :   std_ulogic_vector ;
        strb    :   std_ulogic_vector ;
        keep    :   std_ulogic_vector ;
        user    :   std_ulogic_vector ;
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
