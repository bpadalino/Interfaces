library ieee ;
use     ieee.std_logic_1164.all ;

package axi4mm_common is

    type config_t is record
        DATA_BYTES  :   positive ;
        USER_BYTES  :   natural ;
        USE_ID      :   boolean ;
        USE_QOS     :   boolean ;
        USE_REGION  :   boolean ;
    end record ;

    constant DEFAULT_READ_CONFIG : config_t := (
        DATA_BYTES  =>  16,
        USER_BYTES  =>  0,
        USE_ID      =>  false,
        USE_QOS     =>  false,
        USE_REGION  =>  false
    ) ;

    constant DEFAULT_WRITE_CONFIG : config_t := (
        DATA_BYTES  =>  16,
        USER_BYTES  =>  0,
        USE_ID      =>  false,
        USE_QOS     =>  false,
        USE_REGION  =>  false
    ) ;

    type burst_t is (FIXED, INCR, WRAP, RES) ;
    type resp_t is (OKAY, EXOKAY, SLVERR, DECERR) ;
    type lock_t is (NORMAL, EXCLUSIVE) ;

    function slv(x : burst_t) return std_ulogic_vector ;
    function slv(x : resp_t) return std_ulogic_vector ;
    function sl(x : lock_t) return std_ulogic ;

    type burst_lengths_t is array(positive range 2**0 to 2**8) of std_ulogic_vector(7 downto 0) ;

    function burst_lengths return burst_lengths_t ;

    constant LEN : burst_lengths_t := burst_lengths ;

    type prot_t is record
        privileged  :   std_ulogic ;
        nonsecure   :   std_ulogic ;
        instruction :   std_ulogic ;
    end record ;

    function pack(x : prot_t) return std_ulogic_vector ;
    function unpack(x : std_ulogic_vector) return prot_t ;

    type cache_t is record
        bufferable          :   std_ulogic ;
        modifiable          :   std_ulogic ;
        read_allocation     :   std_ulogic ;
        write_allocation    :   std_ulogic ;
    end record ;

    function pack(x : cache_t) return std_ulogic_vector ;
    function unpack(x : std_ulogic_vector) return cache_t ;

    type address_t is record
        addr    :   std_ulogic_vector(31 downto 0) ;
        prot    :   prot_t ;
        size    :   std_ulogic_vector(2 downto 0) ;
        burst   :   burst_t ;
        cache   :   cache_t ;
        id      :   std_ulogic_vector ;
        len     :   std_ulogic_vector(7 downto 0) ;
        lock    :   lock_t ;
        qos     :   std_ulogic_vector ;
        region  :   std_ulogic_vector ;
        user    :   std_ulogic_vector ;
        valid   :   std_ulogic ;
        ready   :   std_ulogic ;
    end record ;

    --function to_string(x : address_t) return string ;

    view address_master of address_t is
        addr      :   out ;
        prot      :   out ;
        size      :   out ;
        burst     :   out ;
        cache     :   out ;
        id        :   out ;
        len       :   out ;
        lock      :   out ;
        qos       :   out ;
        region    :   out ;
        user      :   out ;
        valid     :   out ;
        ready     :   in ;
    end view ;

    alias address_slave is address_master'converse ;

    type bresp_t is record
        resp       :   resp_t ;
        valid      :   std_ulogic ;
        ready      :   std_ulogic ;
        id         :   std_ulogic_vector ;
        user       :   std_ulogic_vector ;
    end record ;

    --function to_string(x : bresp_t) return string ;

    view bresp_master of bresp_t is
        resp       :   in ;
        valid      :   in ;
        ready      :   out ;
        id         :   in ;
        user       :   in ;
    end view ;

    alias bresp_slave is bresp_master'converse ;

    type wdata_t is record
        data       :   std_ulogic_vector ;
        stb        :   std_ulogic_vector ;
        valid      :   std_ulogic ;
        last       :   std_ulogic ;
        user       :   std_ulogic_vector ;
        ready      :   std_ulogic ;
    end record ;

    --function to_string(x : wdata_t) return string ;

    view wdata_master of wdata_t is
        data       :   out ;
        stb        :   out ;
        valid      :   out ;
        last       :   out ;
        user       :   out ;
        ready      :   in ;
    end view ;

    alias wdata_slave is wdata_master'converse ;

    type rdata_t is record
        data       :   std_ulogic_vector ;
        valid      :   std_ulogic ;
        last       :   std_ulogic ;
        id         :   std_ulogic_vector ;
        user       :   std_ulogic_vector ;
        ready      :   std_ulogic ;
    end record ;

    --function to_string(x : rdata_t) return string ;

    view rdata_master of rdata_t is
        data        :   in ;
        valid       :   in ;
        last        :   in ;
        id          :   in ;
        user        :   in ;
        ready       :   out ;
    end view ;

    alias rdata_slave is rdata_master'converse ;

end package ;

package body axi4mm_common is

    use ieee.numeric_std.to_unsigned;

    function burst_lengths return burst_lengths_t is
        variable rv : burst_lengths_t ;
    begin
        for idx in rv'range loop
            rv(idx) := std_ulogic_vector(to_unsigned(idx-1, rv(idx)'length)) ;
        end loop ;
        return rv ;
    end function ;

    function pack(x : prot_t) return std_ulogic_vector is
        constant rv : std_ulogic_vector(2 downto 0) := (
            0 => x.privileged,
            1 => x.nonsecure,
            2 => x.instruction
        ) ;
    begin
        return rv ;
    end function ;

    function unpack(x : std_ulogic_vector) return prot_t is
        constant rv : prot_t := (
            instruction => x(2),
            nonsecure   => x(1),
            privileged  => x(0)
        ) ;
    begin
        return rv ;
    end function ;

    function pack(x : cache_t) return std_ulogic_vector is
        constant rv : std_ulogic_vector(3 downto 0) := (
            0 => x.bufferable,
            1 => x.modifiable,
            2 => x.read_allocation,
            3 => x.write_allocation
        ) ;
    begin
        return rv ;
    end function ;

    function unpack(x : std_ulogic_vector) return cache_t is
        constant rv : cache_t := (
            bufferable          => x(0),
            modifiable          => x(1),
            read_allocation     => x(2),
            write_allocation    => x(3)
        ) ;
    begin
        return rv ;
    end function ;

    use ieee.numeric_std.all ;
    use std.reflection.all ;

    --function to_string(x : address_t) return string is
    --    variable mirror : value_mirror := x'reflect ;
    --begin
    --    return to_string(mirror) ;
    --end function ;

    --function to_string(x : bresp_t) return string is
    --    variable mirror : value_mirror := x'reflect ;
    --begin
    --    return to_string(mirror) ;
    --end function ;

    --function to_string(x : wdata_t) return string is
    --    variable mirror : value_mirror := x'reflect ;
    --begin
    --    return to_string(mirror) ;
    --end function ;

    --function to_string(x : rdata_t) return string is
    --    variable mirror : value_mirro := x'reflect ;
    --begin
    --    return to_string(mirror) ;
    --end function ;

    function slv(x : burst_t) return std_ulogic_vector is
    begin
        return std_logic_vector(to_unsigned(burst_t'pos(x),2)) ;
    end function ;

    function slv(x : resp_t) return std_ulogic_vector is
    begin
        return std_logic_vector(to_unsigned(resp_t'pos(x),2)) ;
    end function ;

    function sl(x : lock_t) return std_ulogic is
    begin
        return '0' when x = NORMAL else
               '1' ;
    end function ;

end package body ;

