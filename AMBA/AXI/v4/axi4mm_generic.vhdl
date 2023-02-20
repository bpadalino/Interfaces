use work.axi4mm_common.all ;

package axi4mm_generic is
  generic (
    READ_CONFIG     :   config_t := DEFAULT_READ_CONFIG ;
    WRITE_CONFIG    :   config_t := DEFAULT_WRITE_CONFIG ;
  ) ;

    constant WID_WIDTH   : natural := 0 when WRITE_CONFIG.USE_ID = false else 4 ;
    constant RID_WIDTH   : natural := 0 when READ_CONFIG.USE_ID = false else 4 ;

    subtype WID_RANGE is natural range WID_WIDTH-1 downto 0 ;
    subtype RID_RANGE is natural range RID_WIDTH-1 downto 0 ;

    constant WQOS_WIDTH : natural := 0 when WRITE_CONFIG.USE_QOS = false else 4 ;
    constant RQOS_WIDTH : natural := 0 when READ_CONFIG.USE_QOS = false else 4 ;

    subtype WQOS_RANGE is natural range WQOS_WIDTH-1 downto 0 ;
    subtype RQOS_RANGE is natural range RQOS_WIDTH-1 downto 0 ;

    constant WREGION_WIDTH  :   natural := 0 when WRITE_CONFIG.USE_REGION = false else 4 ;
    constant RREGION_WIDTH  :   natural := 0 when READ_CONFIG.USE_REGION = false else 4 ;

    subtype WREGION_RANGE is natural range WREGION_WIDTH-1 downto 0 ;
    subtype RREGIOn_RANGE is natural range RREGION_WIDTH-1 downto 0 ;

    constant WDATA_WIDTH : natural := WRITE_CONFIG.DATA_BYTES*8 ;
    constant WSTB_WIDTH  : natural := WRITE_CONFIG.DATA_BYTES ;
    constant WUSER_WIDTH : natural := WRITE_CONFIG.USER_BYTES*8 ;

    subtype WDATA_RANGE is natural range WDATA_WIDTH-1 downto 0 ;
    subtype WSTB_RANGE is natural range WSTB_WIDTH-1 downto 0 ;
    subtype WUSER_RANGE is natural range WUSER_WIDTH-1 downto 0 ;

    constant RDATA_WIDTH : natural := READ_CONFIG.DATA_BYTES*8 ;
    constant RUSER_WIDTH : natural := WRITE_CONFIG.USER_BYTES*8 ;

    subtype RDATA_RANGE is natural range RDATA_WIDTH-1 downto 0 ;
    subtype RUSER_RANGE is natural range RUSER_WIDTH-1 downto 0 ;

    type axi4mm_t is record
        aw  :   address_t( id(WID_RANGE), qos(WQOS_RANGE), region(WREGION_RANGE), user(WUSER_RANGE) ) ;
        b   :   bresp_t( id(WID_RANGE), user(WUSER_RANGE) ) ;
        w   :   wdata_t( data(WDATA_RANGE), stb(WSTB_RANGE), user(WUSER_RANGE) ) ;
        ar  :   address_t( id(RID_RANGE), qos(RQOS_RANGE), region(RREGION_RANGE), user(RUSER_RANGE) ) ;
        r   :   rdata_t( id(RID_RANGE), data(RDATA_RANGE), user(RUSER_RANGE) ) ;
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
