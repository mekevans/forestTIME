plot_raw_schema <- arrow::schema(
  CN = double(),
  SRV_CN = double(),
  CTY_CN = double(),
  PREV_PLT_CN = double(),
  INVYR = double(),
  UNITCD = double(),
  PLOT = double(),
  PLOT_STATUS_CD = double(),
  PLOT_NONSAMPLE_REASN_CD = double(),
  MEASYEAR = double(),
  MEASMON = double(),
  MEASDAY = double(),
  REMPER = double(),
  KINDCD = double(),
  DESIGNCD = double(),
  RDDISTCD = double(),
  WATERCD = double(),
  LAT = double(),
  LON = double(),
  ELEV = double(),
  GROW_TYP_CD = double(),
  MORT_TYP_CD = double(),
  P2PANEL = double(),
  P3PANEL = double(),
  ECOSUBCD = utf8(),
  CONGCD = double(),
  MANUAL = double(),
  KINDCD_NC = utf8(),
  QA_STATUS = double(),
  CREATED_BY = utf8(),
  CREATED_DATE = utf8(),
  CREATED_IN_INSTANCE = double(),
  MODIFIED_BY = utf8(),
  MODIFIED_DATE = utf8(),
  MODIFIED_IN_INSTANCE = double(),
  MICROPLOT_LOC = utf8(),
  DECLINATION = utf8(),
  EMAP_HEX = double(),
  SAMP_METHOD_CD = double(),
  SUBP_EXAMINE_CD = double(),
  MACRO_BREAKPOINT_DIA = utf8(),
  INTENSITY = double(),
  CYCLE = double(),
  SUBCYCLE = double(),
  ECO_UNIT_PNW = utf8(),
  TOPO_POSITION_PNW = utf8(),
  NF_SAMPLING_STATUS_CD = double(),
  NF_PLOT_STATUS_CD = utf8(),
  NF_PLOT_NONSAMPLE_REASN_CD = utf8(),
  P2VEG_SAMPLING_STATUS_CD = double(),
  P2VEG_SAMPLING_LEVEL_DETAIL_CD = double(),
  INVASIVE_SAMPLING_STATUS_CD = double(),
  INVASIVE_SPECIMEN_RULE_CD = double(),
  DESIGNCD_P2A = utf8(),
  MANUAL_DB = double(),
  SUBPANEL = double(),
  COLOCATED_CD_RMRS = utf8(),
  CONDCHNGCD_RMRS = utf8(),
  FUTFORCD_RMRS = utf8(),
  MANUAL_NCRS = utf8(),
  MANUAL_NERS = double(),
  MANUAL_RMRS = utf8(),
  PAC_ISLAND_PNWRS = utf8(),
  PLOT_SEASON_NERS = double(),
  PRECIPITATION = utf8(),
  PREV_MICROPLOT_LOC_RMRS = utf8(),
  PREV_PLOT_STATUS_CD_RMRS = utf8(),
  REUSECD1 = double(),
  REUSECD2 = double(),
  REUSECD3 = double(),
  PLOT_UNIQUE_ID = utf8(),
  COUNTYCD = utf8(),
  STATECD = utf8()
)


cond_raw_schema <- arrow::schema(
  CN = double(),
  PLT_CN = double(),
  INVYR = double(),
  UNITCD = double(),
  PLOT = double(),
  CONDID = double(),
  COND_STATUS_CD = double(),
  COND_NONSAMPLE_REASN_CD = double(),
  RESERVCD = double(),
  OWNCD = double(),
  OWNGRPCD = double(),
  FORINDCD = utf8(),
  ADFORCD = utf8(),
  FORTYPCD = double(),
  FLDTYPCD = double(),
  MAPDEN = double(),
  STDAGE = double(),
  STDSZCD = double(),
  FLDSZCD = double(),
  SITECLCD = double(),
  SICOND = double(),
  SIBASE = double(),
  SISP = double(),
  STDORGCD = double(),
  STDORGSP = double(),
  PROP_BASIS = utf8(),
  CONDPROP_UNADJ = double(),
  MICRPROP_UNADJ = double(),
  SUBPPROP_UNADJ = double(),
  MACRPROP_UNADJ = utf8(),
  SLOPE = double(),
  ASPECT = double(),
  PHYSCLCD = double(),
  GSSTKCD = double(),
  ALSTKCD = double(),
  DSTRBCD1 = double(),
  DSTRBYR1 = double(),
  DSTRBCD2 = double(),
  DSTRBYR2 = utf8(),
  DSTRBCD3 = double(),
  DSTRBYR3 = utf8(),
  TRTCD1 = double(),
  TRTYR1 = double(),
  TRTCD2 = double(),
  TRTYR2 = double(),
  TRTCD3 = double(),
  TRTYR3 = utf8(),
  PRESNFCD = double(),
  BALIVE = double(),
  FLDAGE = double(),
  ALSTK = double(),
  GSSTK = double(),
  FORTYPCDCALC = double(),
  HABTYPCD1 = utf8(),
  HABTYPCD1_PUB_CD = utf8(),
  HABTYPCD1_DESCR_PUB_CD = utf8(),
  HABTYPCD2 = utf8(),
  HABTYPCD2_PUB_CD = utf8(),
  HABTYPCD2_DESCR_PUB_CD = utf8(),
  MIXEDCONFCD = utf8(),
  VOL_LOC_GRP = utf8(),
  SITECLCDEST = double(),
  SITETREE_TREE = double(),
  SITECL_METHOD = double(),
  CARBON_DOWN_DEAD = double(),
  CARBON_LITTER = double(),
  CARBON_SOIL_ORG = double(),
  CARBON_UNDERSTORY_AG = double(),
  CARBON_UNDERSTORY_BG = double(),
  CREATED_BY = utf8(),
  CREATED_DATE = utf8(),
  CREATED_IN_INSTANCE = double(),
  MODIFIED_BY = utf8(),
  MODIFIED_DATE = utf8(),
  MODIFIED_IN_INSTANCE = double(),
  CYCLE = double(),
  SUBCYCLE = double(),
  SOIL_ROOTING_DEPTH_PNW = utf8(),
  GROUND_LAND_CLASS_PNW = utf8(),
  PLANT_STOCKABILITY_FACTOR_PNW = utf8(),
  STND_COND_CD_PNWRS = utf8(),
  STND_STRUC_CD_PNWRS = utf8(),
  STUMP_CD_PNWRS = utf8(),
  FIRE_SRS = utf8(),
  GRAZING_SRS = utf8(),
  HARVEST_TYPE1_SRS = utf8(),
  HARVEST_TYPE2_SRS = utf8(),
  HARVEST_TYPE3_SRS = utf8(),
  LAND_USE_SRS = utf8(),
  OPERABILITY_SRS = utf8(),
  STAND_STRUCTURE_SRS = utf8(),
  NF_COND_STATUS_CD = utf8(),
  NF_COND_NONSAMPLE_REASN_CD = utf8(),
  CANOPY_CVR_SAMPLE_METHOD_CD = double(),
  LIVE_CANOPY_CVR_PCT = double(),
  LIVE_MISSING_CANOPY_CVR_PCT = double(),
  NBR_LIVE_STEMS = double(),
  OWNSUBCD = utf8(),
  INDUSTRIALCD_FIADB = utf8(),
  RESERVCD_5 = double(),
  ADMIN_WITHDRAWN_CD = utf8(),
  CHAINING_CD = double(),
  LAND_COVER_CLASS_CD_RET = double(),
  AFFORESTATION_CD = double(),
  PREV_AFFORESTATION_CD = double(),
  DWM_FUELBED_TYPCD = utf8(),
  NVCS_PRIMARY_CLASS = utf8(),
  NVCS_LEVEL_1_CD = double(),
  NVCS_LEVEL_2_CD = utf8(),
  NVCS_LEVEL_3_CD = utf8(),
  NVCS_LEVEL_4_CD = utf8(),
  NVCS_LEVEL_5_CD = utf8(),
  NVCS_LEVEL_6_CD = utf8(),
  NVCS_LEVEL_7_CD = utf8(),
  NVCS_LEVEL_8_CD = utf8(),
  AGE_BASIS_CD_PNWRS = utf8(),
  COND_STATUS_CHNG_CD_RMRS = utf8(),
  CRCOVPCT_RMRS = utf8(),
  DOMINANT_SPECIES1_PNWRS = utf8(),
  DOMINANT_SPECIES2_PNWRS = utf8(),
  DOMINANT_SPECIES3_PNWRS = utf8(),
  DSTRBCD1_P2A = utf8(),
  DSTRBCD2_P2A = utf8(),
  DSTRBCD3_P2A = utf8(),
  DSTRBYR1_P2A = utf8(),
  DSTRBYR2_P2A = utf8(),
  DSTRBYR3_P2A = utf8(),
  FLDTYPCD_30 = double(),
  FOREST_COMMUNITY_PNWRS = utf8(),
  LAND_USECD_RMRS = utf8(),
  MAICF = utf8(),
  PCTBARE_RMRS = utf8(),
  QMD_RMRS = utf8(),
  RANGETYPCD_RMRS = utf8(),
  SDIMAX_RMRS = utf8(),
  SDIPCT_RMRS = utf8(),
  SDI_RMRS = utf8(),
  STAND_STRUCTURE_ME_NERS = utf8(),
  TREES_PRESENT_NCRS = utf8(),
  TREES_PRESENT_NERS = double(),
  TRTCD1_P2A = utf8(),
  TRTCD2_P2A = utf8(),
  TRTCD3_P2A = utf8(),
  TRTOPCD = utf8(),
  TRTYR1_P2A = utf8(),
  TRTYR2_P2A = utf8(),
  TRTYR3_P2A = utf8(),
  LAND_COVER_CLASS_CD = double(),
  SIEQN_REF_CD = utf8(),
  SICOND_FVS = double(),
  SIBASE_FVS = double(),
  SISP_FVS = double(),
  SIEQN_REF_CD_FVS = utf8(),
  MQUADPROP_UNADJ = utf8(),
  SOILPROP_UNADJ = utf8(),
  FOREST_COND_STATUS_CHANGE_CD = double(),
  PLOT_UNIQUE_ID = utf8(),
  COUNTYCD = utf8(),
  STATECD = utf8()
)

tree_schema <- arrow::schema(
  CN = double(),
  PLT_CN = double(),
  PREV_TRE_CN = double(),
  INVYR = double(),
  UNITCD = double(),
  PLOT = double(),
  SUBP = double(),
  TREE = double(),
  CONDID = double(),
  AZIMUTH = utf8(),
  DIST = utf8(),
  PREVCOND = double(),
  STATUSCD = double(),
  SPCD = double(),
  SPGRPCD = double(),
  DIA = double(),
  DIAHTCD = double(),
  HT = double(),
  HTCD = double(),
  ACTUALHT = double(),
  TREECLCD = double(),
  CR = double(),
  CCLCD = double(),
  TREEGRCD = double(),
  AGENTCD = double(),
  CULL = double(),
  DAMLOC1 = double(),
  DAMTYP1 = double(),
  DAMSEV1 = double(),
  DAMLOC2 = double(),
  DAMTYP2 = utf8(),
  DAMSEV2 = utf8(),
  DECAYCD = double(),
  STOCKING = double(),
  WDLDSTEM = utf8(),
  VOLCFNET = double(),
  VOLCFGRS = double(),
  VOLCSNET = double(),
  VOLCSGRS = double(),
  VOLBFNET = double(),
  VOLBFGRS = double(),
  VOLCFSND = double(),
  DIACHECK = double(),
  MORTYR = utf8(),
  SALVCD = double(),
  UNCRCD = double(),
  CPOSCD = double(),
  CLIGHTCD = double(),
  CVIGORCD = double(),
  CDENCD = double(),
  CDIEBKCD = double(),
  TRANSCD = double(),
  TREEHISTCD = double(),
  BHAGE = utf8(),
  TOTAGE = utf8(),
  CULLDEAD = utf8(),
  CULLFORM = utf8(),
  CULLMSTOP = utf8(),
  CULLBF = double(),
  CULLCF = double(),
  BFSND = double(),
  CFSND = double(),
  SAWHT = double(),
  BOLEHT = double(),
  FORMCL = utf8(),
  HTCALC = double(),
  HRDWD_CLUMP_CD = utf8(),
  SITREE = utf8(),
  CREATED_BY = utf8(),
  CREATED_DATE = utf8(),
  CREATED_IN_INSTANCE = double(),
  MODIFIED_BY = utf8(),
  MODIFIED_DATE = utf8(),
  MODIFIED_IN_INSTANCE = double(),
  MORTCD = utf8(),
  HTDMP = double(),
  ROUGHCULL = double(),
  MIST_CL_CD = utf8(),
  CULL_FLD = double(),
  RECONCILECD = double(),
  PREVDIA = double(),
  P2A_GRM_FLG = utf8(),
  TREECLCD_NERS = double(),
  TREECLCD_SRS = utf8(),
  TREECLCD_NCRS = utf8(),
  TREECLCD_RMRS = utf8(),
  STANDING_DEAD_CD = double(),
  PREV_STATUS_CD = double(),
  PREV_WDLDSTEM = utf8(),
  TPA_UNADJ = double(),
  DRYBIO_BOLE = double(),
  DRYBIO_STUMP = double(),
  DRYBIO_BG = double(),
  CARBON_AG = double(),
  CARBON_BG = double(),
  CYCLE = double(),
  SUBCYCLE = double(),
  BORED_CD_PNWRS = utf8(),
  DAMLOC1_PNWRS = utf8(),
  DAMLOC2_PNWRS = utf8(),
  DIACHECK_PNWRS = utf8(),
  DMG_AGENT1_CD_PNWRS = utf8(),
  DMG_AGENT2_CD_PNWRS = utf8(),
  DMG_AGENT3_CD_PNWRS = utf8(),
  MIST_CL_CD_PNWRS = utf8(),
  SEVERITY1_CD_PNWRS = utf8(),
  SEVERITY1A_CD_PNWRS = utf8(),
  SEVERITY1B_CD_PNWRS = utf8(),
  SEVERITY2_CD_PNWRS = utf8(),
  SEVERITY2A_CD_PNWRS = utf8(),
  SEVERITY2B_CD_PNWRS = utf8(),
  SEVERITY3_CD_PNWRS = utf8(),
  UNKNOWN_DAMTYP1_PNWRS = utf8(),
  UNKNOWN_DAMTYP2_PNWRS = utf8(),
  PREV_PNTN_SRS = utf8(),
  DISEASE_SRS = utf8(),
  DIEBACK_SEVERITY_SRS = utf8(),
  DAMAGE_AGENT_CD1 = double(),
  DAMAGE_AGENT_CD2 = double(),
  DAMAGE_AGENT_CD3 = double(),
  CENTROID_DIA = utf8(),
  CENTROID_DIA_HT = utf8(),
  CENTROID_DIA_HT_ACTUAL = utf8(),
  UPPER_DIA = utf8(),
  UPPER_DIA_HT = utf8(),
  VOLCSSND = double(),
  DRYBIO_SAWLOG = double(),
  DAMAGE_AGENT_CD1_SRS = utf8(),
  DAMAGE_AGENT_CD2_SRS = utf8(),
  DAMAGE_AGENT_CD3_SRS = utf8(),
  DRYBIO_AG = double(),
  ACTUALHT_CALC = utf8(),
  ACTUALHT_CALC_CD = utf8(),
  CULL_BF_ROTTEN = double(),
  CULL_BF_ROTTEN_CD = double(),
  CULL_BF_ROUGH = double(),
  CULL_BF_ROUGH_CD = double(),
  PREVDIA_FLD = double(),
  TREECLCD_31_NCRS = utf8(),
  TREE_GRADE_NCRS = double(),
  BOUGHS_AVAILABLE_NCRS = utf8(),
  BOUGHS_HRVST_NCRS = utf8(),
  TREECLCD_31_NERS = double(),
  AGENTCD_NERS = double(),
  BFSNDCD_NERS = double(),
  AGECHKCD_RMRS = utf8(),
  PREV_ACTUALHT_RMRS = utf8(),
  PREV_AGECHKCD_RMRS = utf8(),
  PREV_BHAGE_RMRS = utf8(),
  PREV_HT_RMRS = utf8(),
  PREV_TOTAGE_RMRS = utf8(),
  PREV_TREECLCD_RMRS = utf8(),
  RADAGECD_RMRS = utf8(),
  RADGRW_RMRS = utf8(),
  VOLBSGRS = utf8(),
  VOLBSNET = utf8(),
  SAPLING_FUSIFORM_SRS = utf8(),
  EPIPHYTE_PNWRS = utf8(),
  ROOT_HT_PNWRS = utf8(),
  CAVITY_USE_PNWRS = utf8(),
  CORE_LENGTH_PNWRS = utf8(),
  CULTURALLY_KILLED_PNWRS = utf8(),
  DIA_EST_PNWRS = utf8(),
  GST_PNWRS = utf8(),
  INC10YR_PNWRS = utf8(),
  INC5YRHT_PNWRS = utf8(),
  INC5YR_PNWRS = utf8(),
  RING_COUNT_INNER_2INCHES_PNWRS = utf8(),
  RING_COUNT_PNWRS = utf8(),
  SNAG_DIS_CD_PNWRS = utf8(),
  CONEPRESCD1 = utf8(),
  CONEPRESCD2 = utf8(),
  CONEPRESCD3 = utf8(),
  MASTCD = utf8(),
  VOLTSGRS = double(),
  VOLTSGRS_BARK = double(),
  VOLTSSND = double(),
  VOLTSSND_BARK = double(),
  VOLCFGRS_STUMP = double(),
  VOLCFGRS_STUMP_BARK = double(),
  VOLCFSND_STUMP = double(),
  VOLCFSND_STUMP_BARK = double(),
  VOLCFGRS_BARK = double(),
  VOLCFGRS_TOP = double(),
  VOLCFGRS_TOP_BARK = double(),
  VOLCFSND_BARK = double(),
  VOLCFSND_TOP = double(),
  VOLCFSND_TOP_BARK = double(),
  VOLCFNET_BARK = double(),
  VOLCSGRS_BARK = double(),
  VOLCSSND_BARK = double(),
  VOLCSNET_BARK = double(),
  DRYBIO_STEM = double(),
  DRYBIO_STEM_BARK = double(),
  DRYBIO_STUMP_BARK = double(),
  DRYBIO_BOLE_BARK = double(),
  DRYBIO_BRANCH = double(),
  DRYBIO_FOLIAGE = double(),
  DRYBIO_SAWLOG_BARK = double(),
  TREE_UNIQUE_ID = utf8(),
  PLOT_UNIQUE_ID = utf8(),
  COUNTYCD = utf8(),
  STATECD = utf8()
)

tree_info_schema <- list(
  TREE_UNIQUE_ID = utf8(),
  PLOT_UNIQUE_ID = utf8(),
  NYEARS = double(),
  NYEARS_MEASURED = double(),
  FIRSTYR = double(),
  LASTYR = double(),
  SPCD = double(),
  PLOT = double(),
  SUBPLOT = double(),
  SPCDS = double(),
  COUNTYCD = utf8(),
  STATECD = utf8()
)

