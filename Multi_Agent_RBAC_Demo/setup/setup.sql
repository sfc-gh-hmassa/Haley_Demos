CREATE DATABASE IF NOT EXISTS MULTIAGENT_DEMO;
CREATE SCHEMA IF NOT EXISTS MULTIAGENT_DEMO.BENCH;
USE SCHEMA MULTIAGENT_DEMO.BENCH;
CREATE OR REPLACE TABLE MULTIAGENT_DEMO.BENCH.SALES (
  order_id NUMBER,
  order_date DATE,
  product_id VARCHAR,
  customer_region VARCHAR,
  quantity NUMBER,
  revenue NUMBER(12,2),
  s_plant_attr_00 VARCHAR,
  s_region_attr_01 VARCHAR,
  s_business_unit_attr_02 VARCHAR,
  s_commodity_attr_03 VARCHAR,
  s_supplier_tier_attr_04 VARCHAR,
  s_incoterm_attr_05 VARCHAR,
  s_channel_attr_06 VARCHAR,
  s_segment_attr_07 VARCHAR,
  s_program_attr_08 VARCHAR,
  s_platform_attr_09 VARCHAR,
  s_connector_family_attr_10 VARCHAR,
  s_pin_count_attr_11 VARCHAR,
  s_material_attr_12 VARCHAR,
  s_plating_attr_13 VARCHAR,
  s_currency_attr_14 VARCHAR,
  s_fiscal_period_attr_15 VARCHAR,
  s_planner_attr_16 VARCHAR,
  s_buyer_attr_17 VARCHAR,
  s_warehouse_zone_attr_18 VARCHAR,
  s_lot_class_attr_19 VARCHAR,
  s_plant_attr_20 VARCHAR,
  s_region_attr_21 VARCHAR,
  s_business_unit_attr_22 VARCHAR,
  s_commodity_attr_23 VARCHAR,
  s_supplier_tier_attr_24 VARCHAR,
  s_incoterm_attr_25 VARCHAR,
  s_channel_attr_26 VARCHAR,
  s_segment_attr_27 VARCHAR,
  s_program_attr_28 VARCHAR,
  s_platform_attr_29 VARCHAR,
  s_connector_family_attr_30 VARCHAR,
  s_pin_count_attr_31 VARCHAR,
  s_material_attr_32 VARCHAR,
  s_plating_attr_33 VARCHAR,
  s_currency_attr_34 VARCHAR,
  s_fiscal_period_attr_35 VARCHAR,
  s_planner_attr_36 VARCHAR,
  s_buyer_attr_37 VARCHAR,
  s_warehouse_zone_attr_38 VARCHAR,
  s_lot_class_attr_39 VARCHAR,
  s_plant_attr_40 VARCHAR,
  s_region_attr_41 VARCHAR,
  s_business_unit_attr_42 VARCHAR,
  s_commodity_attr_43 VARCHAR,
  s_supplier_tier_attr_44 VARCHAR,
  s_incoterm_attr_45 VARCHAR,
  s_channel_attr_46 VARCHAR,
  s_segment_attr_47 VARCHAR,
  s_program_attr_48 VARCHAR,
  s_platform_attr_49 VARCHAR,
  s_connector_family_attr_50 VARCHAR,
  s_pin_count_attr_51 VARCHAR,
  s_material_attr_52 VARCHAR,
  s_plating_attr_53 VARCHAR,
  s_currency_attr_54 VARCHAR,
  s_fiscal_period_attr_55 VARCHAR,
  s_planner_attr_56 VARCHAR,
  s_buyer_attr_57 VARCHAR,
  s_warehouse_zone_attr_58 VARCHAR,
  s_lot_class_attr_59 VARCHAR,
  s_plant_attr_60 VARCHAR,
  s_region_attr_61 VARCHAR,
  s_business_unit_attr_62 VARCHAR,
  s_commodity_attr_63 VARCHAR,
  s_supplier_tier_attr_64 VARCHAR,
  s_incoterm_attr_65 VARCHAR,
  s_channel_attr_66 VARCHAR,
  s_segment_attr_67 VARCHAR,
  s_program_attr_68 VARCHAR,
  s_platform_attr_69 VARCHAR,
  s_connector_family_attr_70 VARCHAR,
  s_pin_count_attr_71 VARCHAR,
  s_material_attr_72 VARCHAR,
  s_plating_attr_73 VARCHAR,
  s_currency_attr_74 VARCHAR,
  s_fiscal_period_attr_75 VARCHAR,
  s_planner_attr_76 VARCHAR,
  s_buyer_attr_77 VARCHAR,
  s_warehouse_zone_attr_78 VARCHAR,
  s_lot_class_attr_79 VARCHAR,
  s_plant_attr_80 VARCHAR,
  s_region_attr_81 VARCHAR,
  s_business_unit_attr_82 VARCHAR,
  s_commodity_attr_83 VARCHAR,
  s_supplier_tier_attr_84 VARCHAR,
  s_incoterm_attr_85 VARCHAR,
  s_channel_attr_86 VARCHAR,
  s_segment_attr_87 VARCHAR,
  s_program_attr_88 VARCHAR,
  s_platform_attr_89 VARCHAR,
  s_connector_family_attr_90 VARCHAR,
  s_pin_count_attr_91 VARCHAR,
  s_material_attr_92 VARCHAR,
  s_plating_attr_93 VARCHAR,
  s_currency_attr_94 VARCHAR,
  s_fiscal_period_attr_95 VARCHAR,
  s_planner_attr_96 VARCHAR,
  s_buyer_attr_97 VARCHAR,
  s_warehouse_zone_attr_98 VARCHAR,
  s_lot_class_attr_99 VARCHAR,
  s_plant_attr_100 VARCHAR,
  s_region_attr_101 VARCHAR,
  s_business_unit_attr_102 VARCHAR,
  s_commodity_attr_103 VARCHAR,
  s_supplier_tier_attr_104 VARCHAR,
  s_incoterm_attr_105 VARCHAR,
  s_channel_attr_106 VARCHAR,
  s_segment_attr_107 VARCHAR,
  s_program_attr_108 VARCHAR,
  s_platform_attr_109 VARCHAR,
  s_connector_family_attr_110 VARCHAR,
  s_pin_count_attr_111 VARCHAR,
  s_material_attr_112 VARCHAR,
  s_plating_attr_113 VARCHAR,
  s_currency_attr_114 VARCHAR,
  s_fiscal_period_attr_115 VARCHAR,
  s_planner_attr_116 VARCHAR,
  s_buyer_attr_117 VARCHAR,
  s_warehouse_zone_attr_118 VARCHAR,
  s_lot_class_attr_119 VARCHAR
);
INSERT INTO MULTIAGENT_DEMO.BENCH.SALES
SELECT SEQ4(), DATEADD(day, -UNIFORM(0, 730, RANDOM()), CURRENT_DATE()), GET(ARRAY_CONSTRUCT('P001','P002','P003','P004','P005','P006','P007','P008','P009','P010','P011','P012','P013','P014','P015','P016','P017','P018','P019','P020','P021','P022','P023','P024','P025','P026','P027','P028','P029','P030','P031','P032','P033','P034','P035','P036','P037','P038','P039','P040'), UNIFORM(0, 39, RANDOM()))::VARCHAR, GET(ARRAY_CONSTRUCT('AMER','EMEA','APAC'), UNIFORM(0, 2, RANDOM()))::VARCHAR, UNIFORM(1, 500, RANDOM()), ROUND(UNIFORM(10, 5000, RANDOM()) * 1.37, 2), 'PLANT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'REGION_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUSINESS_UNIT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'COMMODITY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SUPPLIER_TIER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'INCOTERM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CHANNEL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SEGMENT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PROGRAM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATFORM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CONNECTOR_FAMILY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PIN_COUNT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'MATERIAL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATING_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CURRENCY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'FISCAL_PERIOD_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANNER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUYER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'WAREHOUSE_ZONE_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'LOT_CLASS_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'REGION_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUSINESS_UNIT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'COMMODITY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SUPPLIER_TIER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'INCOTERM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CHANNEL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SEGMENT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PROGRAM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATFORM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CONNECTOR_FAMILY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PIN_COUNT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'MATERIAL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATING_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CURRENCY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'FISCAL_PERIOD_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANNER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUYER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'WAREHOUSE_ZONE_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'LOT_CLASS_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'REGION_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUSINESS_UNIT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'COMMODITY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SUPPLIER_TIER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'INCOTERM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CHANNEL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SEGMENT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PROGRAM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATFORM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CONNECTOR_FAMILY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PIN_COUNT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'MATERIAL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATING_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CURRENCY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'FISCAL_PERIOD_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANNER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUYER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'WAREHOUSE_ZONE_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'LOT_CLASS_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'REGION_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUSINESS_UNIT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'COMMODITY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SUPPLIER_TIER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'INCOTERM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CHANNEL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SEGMENT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PROGRAM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATFORM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CONNECTOR_FAMILY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PIN_COUNT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'MATERIAL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATING_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CURRENCY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'FISCAL_PERIOD_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANNER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUYER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'WAREHOUSE_ZONE_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'LOT_CLASS_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'REGION_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUSINESS_UNIT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'COMMODITY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SUPPLIER_TIER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'INCOTERM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CHANNEL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SEGMENT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PROGRAM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATFORM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CONNECTOR_FAMILY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PIN_COUNT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'MATERIAL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATING_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CURRENCY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'FISCAL_PERIOD_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANNER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUYER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'WAREHOUSE_ZONE_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'LOT_CLASS_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'REGION_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUSINESS_UNIT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'COMMODITY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SUPPLIER_TIER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'INCOTERM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CHANNEL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SEGMENT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PROGRAM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATFORM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CONNECTOR_FAMILY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PIN_COUNT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'MATERIAL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATING_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CURRENCY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'FISCAL_PERIOD_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANNER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUYER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'WAREHOUSE_ZONE_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'LOT_CLASS_' || UNIFORM(1, 8, RANDOM())::VARCHAR
FROM TABLE(GENERATOR(ROWCOUNT => 50000));

CREATE OR REPLACE TABLE MULTIAGENT_DEMO.BENCH.INVENTORY (
  snapshot_id NUMBER,
  snapshot_date DATE,
  product_id VARCHAR,
  plant VARCHAR,
  on_hand_qty NUMBER,
  safety_stock_qty NUMBER,
  inventory_value NUMBER(12,2),
  i_plant_attr_00 VARCHAR,
  i_region_attr_01 VARCHAR,
  i_business_unit_attr_02 VARCHAR,
  i_commodity_attr_03 VARCHAR,
  i_supplier_tier_attr_04 VARCHAR,
  i_incoterm_attr_05 VARCHAR,
  i_channel_attr_06 VARCHAR,
  i_segment_attr_07 VARCHAR,
  i_program_attr_08 VARCHAR,
  i_platform_attr_09 VARCHAR,
  i_connector_family_attr_10 VARCHAR,
  i_pin_count_attr_11 VARCHAR,
  i_material_attr_12 VARCHAR,
  i_plating_attr_13 VARCHAR,
  i_currency_attr_14 VARCHAR,
  i_fiscal_period_attr_15 VARCHAR,
  i_planner_attr_16 VARCHAR,
  i_buyer_attr_17 VARCHAR,
  i_warehouse_zone_attr_18 VARCHAR,
  i_lot_class_attr_19 VARCHAR,
  i_plant_attr_20 VARCHAR,
  i_region_attr_21 VARCHAR,
  i_business_unit_attr_22 VARCHAR,
  i_commodity_attr_23 VARCHAR,
  i_supplier_tier_attr_24 VARCHAR,
  i_incoterm_attr_25 VARCHAR,
  i_channel_attr_26 VARCHAR,
  i_segment_attr_27 VARCHAR,
  i_program_attr_28 VARCHAR,
  i_platform_attr_29 VARCHAR,
  i_connector_family_attr_30 VARCHAR,
  i_pin_count_attr_31 VARCHAR,
  i_material_attr_32 VARCHAR,
  i_plating_attr_33 VARCHAR,
  i_currency_attr_34 VARCHAR,
  i_fiscal_period_attr_35 VARCHAR,
  i_planner_attr_36 VARCHAR,
  i_buyer_attr_37 VARCHAR,
  i_warehouse_zone_attr_38 VARCHAR,
  i_lot_class_attr_39 VARCHAR,
  i_plant_attr_40 VARCHAR,
  i_region_attr_41 VARCHAR,
  i_business_unit_attr_42 VARCHAR,
  i_commodity_attr_43 VARCHAR,
  i_supplier_tier_attr_44 VARCHAR,
  i_incoterm_attr_45 VARCHAR,
  i_channel_attr_46 VARCHAR,
  i_segment_attr_47 VARCHAR,
  i_program_attr_48 VARCHAR,
  i_platform_attr_49 VARCHAR,
  i_connector_family_attr_50 VARCHAR,
  i_pin_count_attr_51 VARCHAR,
  i_material_attr_52 VARCHAR,
  i_plating_attr_53 VARCHAR,
  i_currency_attr_54 VARCHAR,
  i_fiscal_period_attr_55 VARCHAR,
  i_planner_attr_56 VARCHAR,
  i_buyer_attr_57 VARCHAR,
  i_warehouse_zone_attr_58 VARCHAR,
  i_lot_class_attr_59 VARCHAR,
  i_plant_attr_60 VARCHAR,
  i_region_attr_61 VARCHAR,
  i_business_unit_attr_62 VARCHAR,
  i_commodity_attr_63 VARCHAR,
  i_supplier_tier_attr_64 VARCHAR,
  i_incoterm_attr_65 VARCHAR,
  i_channel_attr_66 VARCHAR,
  i_segment_attr_67 VARCHAR,
  i_program_attr_68 VARCHAR,
  i_platform_attr_69 VARCHAR,
  i_connector_family_attr_70 VARCHAR,
  i_pin_count_attr_71 VARCHAR,
  i_material_attr_72 VARCHAR,
  i_plating_attr_73 VARCHAR,
  i_currency_attr_74 VARCHAR,
  i_fiscal_period_attr_75 VARCHAR,
  i_planner_attr_76 VARCHAR,
  i_buyer_attr_77 VARCHAR,
  i_warehouse_zone_attr_78 VARCHAR,
  i_lot_class_attr_79 VARCHAR,
  i_plant_attr_80 VARCHAR,
  i_region_attr_81 VARCHAR,
  i_business_unit_attr_82 VARCHAR,
  i_commodity_attr_83 VARCHAR,
  i_supplier_tier_attr_84 VARCHAR,
  i_incoterm_attr_85 VARCHAR,
  i_channel_attr_86 VARCHAR,
  i_segment_attr_87 VARCHAR,
  i_program_attr_88 VARCHAR,
  i_platform_attr_89 VARCHAR,
  i_connector_family_attr_90 VARCHAR,
  i_pin_count_attr_91 VARCHAR,
  i_material_attr_92 VARCHAR,
  i_plating_attr_93 VARCHAR,
  i_currency_attr_94 VARCHAR,
  i_fiscal_period_attr_95 VARCHAR,
  i_planner_attr_96 VARCHAR,
  i_buyer_attr_97 VARCHAR,
  i_warehouse_zone_attr_98 VARCHAR,
  i_lot_class_attr_99 VARCHAR,
  i_plant_attr_100 VARCHAR,
  i_region_attr_101 VARCHAR,
  i_business_unit_attr_102 VARCHAR,
  i_commodity_attr_103 VARCHAR,
  i_supplier_tier_attr_104 VARCHAR,
  i_incoterm_attr_105 VARCHAR,
  i_channel_attr_106 VARCHAR,
  i_segment_attr_107 VARCHAR,
  i_program_attr_108 VARCHAR,
  i_platform_attr_109 VARCHAR,
  i_connector_family_attr_110 VARCHAR,
  i_pin_count_attr_111 VARCHAR,
  i_material_attr_112 VARCHAR,
  i_plating_attr_113 VARCHAR,
  i_currency_attr_114 VARCHAR,
  i_fiscal_period_attr_115 VARCHAR,
  i_planner_attr_116 VARCHAR,
  i_buyer_attr_117 VARCHAR,
  i_warehouse_zone_attr_118 VARCHAR,
  i_lot_class_attr_119 VARCHAR
);
INSERT INTO MULTIAGENT_DEMO.BENCH.INVENTORY
SELECT SEQ4(), DATEADD(day, -UNIFORM(0, 365, RANDOM()), CURRENT_DATE()), GET(ARRAY_CONSTRUCT('P001','P002','P003','P004','P005','P006','P007','P008','P009','P010','P011','P012','P013','P014','P015','P016','P017','P018','P019','P020','P021','P022','P023','P024','P025','P026','P027','P028','P029','P030','P031','P032','P033','P034','P035','P036','P037','P038','P039','P040'), UNIFORM(0, 39, RANDOM()))::VARCHAR, GET(ARRAY_CONSTRUCT('LISLE','GUADALAJARA','PENANG','SHANNON'), UNIFORM(0, 3, RANDOM()))::VARCHAR, UNIFORM(0, 20000, RANDOM()), UNIFORM(500, 5000, RANDOM()), ROUND(UNIFORM(100, 90000, RANDOM()) * 1.11, 2), 'PLANT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'REGION_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUSINESS_UNIT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'COMMODITY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SUPPLIER_TIER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'INCOTERM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CHANNEL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SEGMENT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PROGRAM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATFORM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CONNECTOR_FAMILY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PIN_COUNT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'MATERIAL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATING_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CURRENCY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'FISCAL_PERIOD_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANNER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUYER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'WAREHOUSE_ZONE_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'LOT_CLASS_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'REGION_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUSINESS_UNIT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'COMMODITY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SUPPLIER_TIER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'INCOTERM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CHANNEL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SEGMENT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PROGRAM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATFORM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CONNECTOR_FAMILY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PIN_COUNT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'MATERIAL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATING_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CURRENCY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'FISCAL_PERIOD_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANNER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUYER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'WAREHOUSE_ZONE_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'LOT_CLASS_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'REGION_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUSINESS_UNIT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'COMMODITY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SUPPLIER_TIER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'INCOTERM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CHANNEL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SEGMENT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PROGRAM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATFORM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CONNECTOR_FAMILY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PIN_COUNT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'MATERIAL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATING_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CURRENCY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'FISCAL_PERIOD_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANNER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUYER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'WAREHOUSE_ZONE_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'LOT_CLASS_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'REGION_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUSINESS_UNIT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'COMMODITY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SUPPLIER_TIER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'INCOTERM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CHANNEL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SEGMENT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PROGRAM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATFORM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CONNECTOR_FAMILY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PIN_COUNT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'MATERIAL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATING_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CURRENCY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'FISCAL_PERIOD_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANNER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUYER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'WAREHOUSE_ZONE_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'LOT_CLASS_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'REGION_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUSINESS_UNIT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'COMMODITY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SUPPLIER_TIER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'INCOTERM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CHANNEL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SEGMENT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PROGRAM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATFORM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CONNECTOR_FAMILY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PIN_COUNT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'MATERIAL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATING_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CURRENCY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'FISCAL_PERIOD_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANNER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUYER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'WAREHOUSE_ZONE_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'LOT_CLASS_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'REGION_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUSINESS_UNIT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'COMMODITY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SUPPLIER_TIER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'INCOTERM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CHANNEL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'SEGMENT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PROGRAM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATFORM_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CONNECTOR_FAMILY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PIN_COUNT_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'MATERIAL_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLATING_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'CURRENCY_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'FISCAL_PERIOD_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'PLANNER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'BUYER_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'WAREHOUSE_ZONE_' || UNIFORM(1, 8, RANDOM())::VARCHAR, 'LOT_CLASS_' || UNIFORM(1, 8, RANDOM())::VARCHAR
FROM TABLE(GENERATOR(ROWCOUNT => 20000));

CREATE OR REPLACE SEMANTIC VIEW MULTIAGENT_DEMO.BENCH.SALES_SV
  TABLES (sales AS MULTIAGENT_DEMO.BENCH.SALES PRIMARY KEY (order_id) COMMENT = 'Sales fact table')
  FACTS (
    sales.quantity AS quantity,
    sales.revenue AS revenue
  )
  DIMENSIONS (
    sales.order_date AS order_date WITH SYNONYMS = ('date', 'order day') COMMENT = 'Date the order was booked',
    sales.product_id AS product_id WITH SYNONYMS = ('product', 'part number', 'sku') COMMENT = 'Part number',
    sales.customer_region AS customer_region WITH SYNONYMS = ('region', 'geo') COMMENT = 'Customer sales region',
    sales.s_plant_attr_00 AS s_plant_attr_00 WITH SYNONYMS = ('plant', 'plant code') COMMENT = 'Sales attribute s_plant_attr_00. Represents the plant classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_region_attr_01 AS s_region_attr_01 WITH SYNONYMS = ('region', 'region code') COMMENT = 'Sales attribute s_region_attr_01. Represents the region classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_business_unit_attr_02 AS s_business_unit_attr_02 WITH SYNONYMS = ('business unit', 'business_unit code') COMMENT = 'Sales attribute s_business_unit_attr_02. Represents the business unit classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_commodity_attr_03 AS s_commodity_attr_03 WITH SYNONYMS = ('commodity', 'commodity code') COMMENT = 'Sales attribute s_commodity_attr_03. Represents the commodity classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_supplier_tier_attr_04 AS s_supplier_tier_attr_04 WITH SYNONYMS = ('supplier tier', 'supplier_tier code') COMMENT = 'Sales attribute s_supplier_tier_attr_04. Represents the supplier tier classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_incoterm_attr_05 AS s_incoterm_attr_05 WITH SYNONYMS = ('incoterm', 'incoterm code') COMMENT = 'Sales attribute s_incoterm_attr_05. Represents the incoterm classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_channel_attr_06 AS s_channel_attr_06 WITH SYNONYMS = ('channel', 'channel code') COMMENT = 'Sales attribute s_channel_attr_06. Represents the channel classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_segment_attr_07 AS s_segment_attr_07 WITH SYNONYMS = ('segment', 'segment code') COMMENT = 'Sales attribute s_segment_attr_07. Represents the segment classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_program_attr_08 AS s_program_attr_08 WITH SYNONYMS = ('program', 'program code') COMMENT = 'Sales attribute s_program_attr_08. Represents the program classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_platform_attr_09 AS s_platform_attr_09 WITH SYNONYMS = ('platform', 'platform code') COMMENT = 'Sales attribute s_platform_attr_09. Represents the platform classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_connector_family_attr_10 AS s_connector_family_attr_10 WITH SYNONYMS = ('connector family', 'connector_family code') COMMENT = 'Sales attribute s_connector_family_attr_10. Represents the connector family classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_pin_count_attr_11 AS s_pin_count_attr_11 WITH SYNONYMS = ('pin count', 'pin_count code') COMMENT = 'Sales attribute s_pin_count_attr_11. Represents the pin count classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_material_attr_12 AS s_material_attr_12 WITH SYNONYMS = ('material', 'material code') COMMENT = 'Sales attribute s_material_attr_12. Represents the material classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_plating_attr_13 AS s_plating_attr_13 WITH SYNONYMS = ('plating', 'plating code') COMMENT = 'Sales attribute s_plating_attr_13. Represents the plating classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_currency_attr_14 AS s_currency_attr_14 WITH SYNONYMS = ('currency', 'currency code') COMMENT = 'Sales attribute s_currency_attr_14. Represents the currency classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_fiscal_period_attr_15 AS s_fiscal_period_attr_15 WITH SYNONYMS = ('fiscal period', 'fiscal_period code') COMMENT = 'Sales attribute s_fiscal_period_attr_15. Represents the fiscal period classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_planner_attr_16 AS s_planner_attr_16 WITH SYNONYMS = ('planner', 'planner code') COMMENT = 'Sales attribute s_planner_attr_16. Represents the planner classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_buyer_attr_17 AS s_buyer_attr_17 WITH SYNONYMS = ('buyer', 'buyer code') COMMENT = 'Sales attribute s_buyer_attr_17. Represents the buyer classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_warehouse_zone_attr_18 AS s_warehouse_zone_attr_18 WITH SYNONYMS = ('warehouse zone', 'warehouse_zone code') COMMENT = 'Sales attribute s_warehouse_zone_attr_18. Represents the warehouse zone classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_lot_class_attr_19 AS s_lot_class_attr_19 WITH SYNONYMS = ('lot class', 'lot_class code') COMMENT = 'Sales attribute s_lot_class_attr_19. Represents the lot class classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_plant_attr_20 AS s_plant_attr_20 WITH SYNONYMS = ('plant', 'plant code') COMMENT = 'Sales attribute s_plant_attr_20. Represents the plant classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_region_attr_21 AS s_region_attr_21 WITH SYNONYMS = ('region', 'region code') COMMENT = 'Sales attribute s_region_attr_21. Represents the region classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_business_unit_attr_22 AS s_business_unit_attr_22 WITH SYNONYMS = ('business unit', 'business_unit code') COMMENT = 'Sales attribute s_business_unit_attr_22. Represents the business unit classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_commodity_attr_23 AS s_commodity_attr_23 WITH SYNONYMS = ('commodity', 'commodity code') COMMENT = 'Sales attribute s_commodity_attr_23. Represents the commodity classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_supplier_tier_attr_24 AS s_supplier_tier_attr_24 WITH SYNONYMS = ('supplier tier', 'supplier_tier code') COMMENT = 'Sales attribute s_supplier_tier_attr_24. Represents the supplier tier classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_incoterm_attr_25 AS s_incoterm_attr_25 WITH SYNONYMS = ('incoterm', 'incoterm code') COMMENT = 'Sales attribute s_incoterm_attr_25. Represents the incoterm classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_channel_attr_26 AS s_channel_attr_26 WITH SYNONYMS = ('channel', 'channel code') COMMENT = 'Sales attribute s_channel_attr_26. Represents the channel classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_segment_attr_27 AS s_segment_attr_27 WITH SYNONYMS = ('segment', 'segment code') COMMENT = 'Sales attribute s_segment_attr_27. Represents the segment classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_program_attr_28 AS s_program_attr_28 WITH SYNONYMS = ('program', 'program code') COMMENT = 'Sales attribute s_program_attr_28. Represents the program classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_platform_attr_29 AS s_platform_attr_29 WITH SYNONYMS = ('platform', 'platform code') COMMENT = 'Sales attribute s_platform_attr_29. Represents the platform classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_connector_family_attr_30 AS s_connector_family_attr_30 WITH SYNONYMS = ('connector family', 'connector_family code') COMMENT = 'Sales attribute s_connector_family_attr_30. Represents the connector family classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_pin_count_attr_31 AS s_pin_count_attr_31 WITH SYNONYMS = ('pin count', 'pin_count code') COMMENT = 'Sales attribute s_pin_count_attr_31. Represents the pin count classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_material_attr_32 AS s_material_attr_32 WITH SYNONYMS = ('material', 'material code') COMMENT = 'Sales attribute s_material_attr_32. Represents the material classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_plating_attr_33 AS s_plating_attr_33 WITH SYNONYMS = ('plating', 'plating code') COMMENT = 'Sales attribute s_plating_attr_33. Represents the plating classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_currency_attr_34 AS s_currency_attr_34 WITH SYNONYMS = ('currency', 'currency code') COMMENT = 'Sales attribute s_currency_attr_34. Represents the currency classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_fiscal_period_attr_35 AS s_fiscal_period_attr_35 WITH SYNONYMS = ('fiscal period', 'fiscal_period code') COMMENT = 'Sales attribute s_fiscal_period_attr_35. Represents the fiscal period classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_planner_attr_36 AS s_planner_attr_36 WITH SYNONYMS = ('planner', 'planner code') COMMENT = 'Sales attribute s_planner_attr_36. Represents the planner classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_buyer_attr_37 AS s_buyer_attr_37 WITH SYNONYMS = ('buyer', 'buyer code') COMMENT = 'Sales attribute s_buyer_attr_37. Represents the buyer classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_warehouse_zone_attr_38 AS s_warehouse_zone_attr_38 WITH SYNONYMS = ('warehouse zone', 'warehouse_zone code') COMMENT = 'Sales attribute s_warehouse_zone_attr_38. Represents the warehouse zone classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_lot_class_attr_39 AS s_lot_class_attr_39 WITH SYNONYMS = ('lot class', 'lot_class code') COMMENT = 'Sales attribute s_lot_class_attr_39. Represents the lot class classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_plant_attr_40 AS s_plant_attr_40 WITH SYNONYMS = ('plant', 'plant code') COMMENT = 'Sales attribute s_plant_attr_40. Represents the plant classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_region_attr_41 AS s_region_attr_41 WITH SYNONYMS = ('region', 'region code') COMMENT = 'Sales attribute s_region_attr_41. Represents the region classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_business_unit_attr_42 AS s_business_unit_attr_42 WITH SYNONYMS = ('business unit', 'business_unit code') COMMENT = 'Sales attribute s_business_unit_attr_42. Represents the business unit classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_commodity_attr_43 AS s_commodity_attr_43 WITH SYNONYMS = ('commodity', 'commodity code') COMMENT = 'Sales attribute s_commodity_attr_43. Represents the commodity classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_supplier_tier_attr_44 AS s_supplier_tier_attr_44 WITH SYNONYMS = ('supplier tier', 'supplier_tier code') COMMENT = 'Sales attribute s_supplier_tier_attr_44. Represents the supplier tier classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_incoterm_attr_45 AS s_incoterm_attr_45 WITH SYNONYMS = ('incoterm', 'incoterm code') COMMENT = 'Sales attribute s_incoterm_attr_45. Represents the incoterm classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_channel_attr_46 AS s_channel_attr_46 WITH SYNONYMS = ('channel', 'channel code') COMMENT = 'Sales attribute s_channel_attr_46. Represents the channel classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_segment_attr_47 AS s_segment_attr_47 WITH SYNONYMS = ('segment', 'segment code') COMMENT = 'Sales attribute s_segment_attr_47. Represents the segment classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_program_attr_48 AS s_program_attr_48 WITH SYNONYMS = ('program', 'program code') COMMENT = 'Sales attribute s_program_attr_48. Represents the program classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_platform_attr_49 AS s_platform_attr_49 WITH SYNONYMS = ('platform', 'platform code') COMMENT = 'Sales attribute s_platform_attr_49. Represents the platform classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_connector_family_attr_50 AS s_connector_family_attr_50 WITH SYNONYMS = ('connector family', 'connector_family code') COMMENT = 'Sales attribute s_connector_family_attr_50. Represents the connector family classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_pin_count_attr_51 AS s_pin_count_attr_51 WITH SYNONYMS = ('pin count', 'pin_count code') COMMENT = 'Sales attribute s_pin_count_attr_51. Represents the pin count classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_material_attr_52 AS s_material_attr_52 WITH SYNONYMS = ('material', 'material code') COMMENT = 'Sales attribute s_material_attr_52. Represents the material classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_plating_attr_53 AS s_plating_attr_53 WITH SYNONYMS = ('plating', 'plating code') COMMENT = 'Sales attribute s_plating_attr_53. Represents the plating classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_currency_attr_54 AS s_currency_attr_54 WITH SYNONYMS = ('currency', 'currency code') COMMENT = 'Sales attribute s_currency_attr_54. Represents the currency classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_fiscal_period_attr_55 AS s_fiscal_period_attr_55 WITH SYNONYMS = ('fiscal period', 'fiscal_period code') COMMENT = 'Sales attribute s_fiscal_period_attr_55. Represents the fiscal period classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_planner_attr_56 AS s_planner_attr_56 WITH SYNONYMS = ('planner', 'planner code') COMMENT = 'Sales attribute s_planner_attr_56. Represents the planner classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_buyer_attr_57 AS s_buyer_attr_57 WITH SYNONYMS = ('buyer', 'buyer code') COMMENT = 'Sales attribute s_buyer_attr_57. Represents the buyer classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_warehouse_zone_attr_58 AS s_warehouse_zone_attr_58 WITH SYNONYMS = ('warehouse zone', 'warehouse_zone code') COMMENT = 'Sales attribute s_warehouse_zone_attr_58. Represents the warehouse zone classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_lot_class_attr_59 AS s_lot_class_attr_59 WITH SYNONYMS = ('lot class', 'lot_class code') COMMENT = 'Sales attribute s_lot_class_attr_59. Represents the lot class classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_plant_attr_60 AS s_plant_attr_60 WITH SYNONYMS = ('plant', 'plant code') COMMENT = 'Sales attribute s_plant_attr_60. Represents the plant classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_region_attr_61 AS s_region_attr_61 WITH SYNONYMS = ('region', 'region code') COMMENT = 'Sales attribute s_region_attr_61. Represents the region classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_business_unit_attr_62 AS s_business_unit_attr_62 WITH SYNONYMS = ('business unit', 'business_unit code') COMMENT = 'Sales attribute s_business_unit_attr_62. Represents the business unit classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_commodity_attr_63 AS s_commodity_attr_63 WITH SYNONYMS = ('commodity', 'commodity code') COMMENT = 'Sales attribute s_commodity_attr_63. Represents the commodity classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_supplier_tier_attr_64 AS s_supplier_tier_attr_64 WITH SYNONYMS = ('supplier tier', 'supplier_tier code') COMMENT = 'Sales attribute s_supplier_tier_attr_64. Represents the supplier tier classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_incoterm_attr_65 AS s_incoterm_attr_65 WITH SYNONYMS = ('incoterm', 'incoterm code') COMMENT = 'Sales attribute s_incoterm_attr_65. Represents the incoterm classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_channel_attr_66 AS s_channel_attr_66 WITH SYNONYMS = ('channel', 'channel code') COMMENT = 'Sales attribute s_channel_attr_66. Represents the channel classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_segment_attr_67 AS s_segment_attr_67 WITH SYNONYMS = ('segment', 'segment code') COMMENT = 'Sales attribute s_segment_attr_67. Represents the segment classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_program_attr_68 AS s_program_attr_68 WITH SYNONYMS = ('program', 'program code') COMMENT = 'Sales attribute s_program_attr_68. Represents the program classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_platform_attr_69 AS s_platform_attr_69 WITH SYNONYMS = ('platform', 'platform code') COMMENT = 'Sales attribute s_platform_attr_69. Represents the platform classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_connector_family_attr_70 AS s_connector_family_attr_70 WITH SYNONYMS = ('connector family', 'connector_family code') COMMENT = 'Sales attribute s_connector_family_attr_70. Represents the connector family classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_pin_count_attr_71 AS s_pin_count_attr_71 WITH SYNONYMS = ('pin count', 'pin_count code') COMMENT = 'Sales attribute s_pin_count_attr_71. Represents the pin count classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_material_attr_72 AS s_material_attr_72 WITH SYNONYMS = ('material', 'material code') COMMENT = 'Sales attribute s_material_attr_72. Represents the material classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_plating_attr_73 AS s_plating_attr_73 WITH SYNONYMS = ('plating', 'plating code') COMMENT = 'Sales attribute s_plating_attr_73. Represents the plating classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_currency_attr_74 AS s_currency_attr_74 WITH SYNONYMS = ('currency', 'currency code') COMMENT = 'Sales attribute s_currency_attr_74. Represents the currency classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_fiscal_period_attr_75 AS s_fiscal_period_attr_75 WITH SYNONYMS = ('fiscal period', 'fiscal_period code') COMMENT = 'Sales attribute s_fiscal_period_attr_75. Represents the fiscal period classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_planner_attr_76 AS s_planner_attr_76 WITH SYNONYMS = ('planner', 'planner code') COMMENT = 'Sales attribute s_planner_attr_76. Represents the planner classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_buyer_attr_77 AS s_buyer_attr_77 WITH SYNONYMS = ('buyer', 'buyer code') COMMENT = 'Sales attribute s_buyer_attr_77. Represents the buyer classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_warehouse_zone_attr_78 AS s_warehouse_zone_attr_78 WITH SYNONYMS = ('warehouse zone', 'warehouse_zone code') COMMENT = 'Sales attribute s_warehouse_zone_attr_78. Represents the warehouse zone classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_lot_class_attr_79 AS s_lot_class_attr_79 WITH SYNONYMS = ('lot class', 'lot_class code') COMMENT = 'Sales attribute s_lot_class_attr_79. Represents the lot class classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_plant_attr_80 AS s_plant_attr_80 WITH SYNONYMS = ('plant', 'plant code') COMMENT = 'Sales attribute s_plant_attr_80. Represents the plant classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_region_attr_81 AS s_region_attr_81 WITH SYNONYMS = ('region', 'region code') COMMENT = 'Sales attribute s_region_attr_81. Represents the region classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_business_unit_attr_82 AS s_business_unit_attr_82 WITH SYNONYMS = ('business unit', 'business_unit code') COMMENT = 'Sales attribute s_business_unit_attr_82. Represents the business unit classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_commodity_attr_83 AS s_commodity_attr_83 WITH SYNONYMS = ('commodity', 'commodity code') COMMENT = 'Sales attribute s_commodity_attr_83. Represents the commodity classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_supplier_tier_attr_84 AS s_supplier_tier_attr_84 WITH SYNONYMS = ('supplier tier', 'supplier_tier code') COMMENT = 'Sales attribute s_supplier_tier_attr_84. Represents the supplier tier classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_incoterm_attr_85 AS s_incoterm_attr_85 WITH SYNONYMS = ('incoterm', 'incoterm code') COMMENT = 'Sales attribute s_incoterm_attr_85. Represents the incoterm classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_channel_attr_86 AS s_channel_attr_86 WITH SYNONYMS = ('channel', 'channel code') COMMENT = 'Sales attribute s_channel_attr_86. Represents the channel classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_segment_attr_87 AS s_segment_attr_87 WITH SYNONYMS = ('segment', 'segment code') COMMENT = 'Sales attribute s_segment_attr_87. Represents the segment classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_program_attr_88 AS s_program_attr_88 WITH SYNONYMS = ('program', 'program code') COMMENT = 'Sales attribute s_program_attr_88. Represents the program classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_platform_attr_89 AS s_platform_attr_89 WITH SYNONYMS = ('platform', 'platform code') COMMENT = 'Sales attribute s_platform_attr_89. Represents the platform classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_connector_family_attr_90 AS s_connector_family_attr_90 WITH SYNONYMS = ('connector family', 'connector_family code') COMMENT = 'Sales attribute s_connector_family_attr_90. Represents the connector family classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_pin_count_attr_91 AS s_pin_count_attr_91 WITH SYNONYMS = ('pin count', 'pin_count code') COMMENT = 'Sales attribute s_pin_count_attr_91. Represents the pin count classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_material_attr_92 AS s_material_attr_92 WITH SYNONYMS = ('material', 'material code') COMMENT = 'Sales attribute s_material_attr_92. Represents the material classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_plating_attr_93 AS s_plating_attr_93 WITH SYNONYMS = ('plating', 'plating code') COMMENT = 'Sales attribute s_plating_attr_93. Represents the plating classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_currency_attr_94 AS s_currency_attr_94 WITH SYNONYMS = ('currency', 'currency code') COMMENT = 'Sales attribute s_currency_attr_94. Represents the currency classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_fiscal_period_attr_95 AS s_fiscal_period_attr_95 WITH SYNONYMS = ('fiscal period', 'fiscal_period code') COMMENT = 'Sales attribute s_fiscal_period_attr_95. Represents the fiscal period classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_planner_attr_96 AS s_planner_attr_96 WITH SYNONYMS = ('planner', 'planner code') COMMENT = 'Sales attribute s_planner_attr_96. Represents the planner classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_buyer_attr_97 AS s_buyer_attr_97 WITH SYNONYMS = ('buyer', 'buyer code') COMMENT = 'Sales attribute s_buyer_attr_97. Represents the buyer classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_warehouse_zone_attr_98 AS s_warehouse_zone_attr_98 WITH SYNONYMS = ('warehouse zone', 'warehouse_zone code') COMMENT = 'Sales attribute s_warehouse_zone_attr_98. Represents the warehouse zone classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_lot_class_attr_99 AS s_lot_class_attr_99 WITH SYNONYMS = ('lot class', 'lot_class code') COMMENT = 'Sales attribute s_lot_class_attr_99. Represents the lot class classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_plant_attr_100 AS s_plant_attr_100 WITH SYNONYMS = ('plant', 'plant code') COMMENT = 'Sales attribute s_plant_attr_100. Represents the plant classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_region_attr_101 AS s_region_attr_101 WITH SYNONYMS = ('region', 'region code') COMMENT = 'Sales attribute s_region_attr_101. Represents the region classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_business_unit_attr_102 AS s_business_unit_attr_102 WITH SYNONYMS = ('business unit', 'business_unit code') COMMENT = 'Sales attribute s_business_unit_attr_102. Represents the business unit classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_commodity_attr_103 AS s_commodity_attr_103 WITH SYNONYMS = ('commodity', 'commodity code') COMMENT = 'Sales attribute s_commodity_attr_103. Represents the commodity classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_supplier_tier_attr_104 AS s_supplier_tier_attr_104 WITH SYNONYMS = ('supplier tier', 'supplier_tier code') COMMENT = 'Sales attribute s_supplier_tier_attr_104. Represents the supplier tier classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_incoterm_attr_105 AS s_incoterm_attr_105 WITH SYNONYMS = ('incoterm', 'incoterm code') COMMENT = 'Sales attribute s_incoterm_attr_105. Represents the incoterm classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_channel_attr_106 AS s_channel_attr_106 WITH SYNONYMS = ('channel', 'channel code') COMMENT = 'Sales attribute s_channel_attr_106. Represents the channel classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_segment_attr_107 AS s_segment_attr_107 WITH SYNONYMS = ('segment', 'segment code') COMMENT = 'Sales attribute s_segment_attr_107. Represents the segment classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_program_attr_108 AS s_program_attr_108 WITH SYNONYMS = ('program', 'program code') COMMENT = 'Sales attribute s_program_attr_108. Represents the program classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_platform_attr_109 AS s_platform_attr_109 WITH SYNONYMS = ('platform', 'platform code') COMMENT = 'Sales attribute s_platform_attr_109. Represents the platform classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_connector_family_attr_110 AS s_connector_family_attr_110 WITH SYNONYMS = ('connector family', 'connector_family code') COMMENT = 'Sales attribute s_connector_family_attr_110. Represents the connector family classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_pin_count_attr_111 AS s_pin_count_attr_111 WITH SYNONYMS = ('pin count', 'pin_count code') COMMENT = 'Sales attribute s_pin_count_attr_111. Represents the pin count classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_material_attr_112 AS s_material_attr_112 WITH SYNONYMS = ('material', 'material code') COMMENT = 'Sales attribute s_material_attr_112. Represents the material classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_plating_attr_113 AS s_plating_attr_113 WITH SYNONYMS = ('plating', 'plating code') COMMENT = 'Sales attribute s_plating_attr_113. Represents the plating classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_currency_attr_114 AS s_currency_attr_114 WITH SYNONYMS = ('currency', 'currency code') COMMENT = 'Sales attribute s_currency_attr_114. Represents the currency classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_fiscal_period_attr_115 AS s_fiscal_period_attr_115 WITH SYNONYMS = ('fiscal period', 'fiscal_period code') COMMENT = 'Sales attribute s_fiscal_period_attr_115. Represents the fiscal period classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_planner_attr_116 AS s_planner_attr_116 WITH SYNONYMS = ('planner', 'planner code') COMMENT = 'Sales attribute s_planner_attr_116. Represents the planner classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_buyer_attr_117 AS s_buyer_attr_117 WITH SYNONYMS = ('buyer', 'buyer code') COMMENT = 'Sales attribute s_buyer_attr_117. Represents the buyer classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_warehouse_zone_attr_118 AS s_warehouse_zone_attr_118 WITH SYNONYMS = ('warehouse zone', 'warehouse_zone code') COMMENT = 'Sales attribute s_warehouse_zone_attr_118. Represents the warehouse zone classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    sales.s_lot_class_attr_119 AS s_lot_class_attr_119 WITH SYNONYMS = ('lot class', 'lot_class code') COMMENT = 'Sales attribute s_lot_class_attr_119. Represents the lot class classification used by the Sales reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.'
  )
  METRICS (
    sales.total_revenue AS SUM(sales.revenue) COMMENT = 'Total sales revenue in USD',
    sales.total_units AS SUM(sales.quantity) COMMENT = 'Total units sold',
    sales.order_count AS COUNT(sales.order_id) COMMENT = 'Number of orders'
  )
  COMMENT = 'Sales semantic view for the A2A benchmark';

CREATE OR REPLACE SEMANTIC VIEW MULTIAGENT_DEMO.BENCH.INVENTORY_SV
  TABLES (inv AS MULTIAGENT_DEMO.BENCH.INVENTORY PRIMARY KEY (snapshot_id) COMMENT = 'Inventory fact table')
  FACTS (
    inv.on_hand_qty AS on_hand_qty,
    inv.safety_stock_qty AS safety_stock_qty,
    inv.inventory_value AS inventory_value
  )
  DIMENSIONS (
    inv.snapshot_date AS snapshot_date WITH SYNONYMS = ('date', 'as of date') COMMENT = 'Inventory snapshot date',
    inv.product_id AS product_id WITH SYNONYMS = ('product', 'part number', 'sku') COMMENT = 'Part number',
    inv.plant AS plant WITH SYNONYMS = ('site', 'factory') COMMENT = 'Manufacturing plant',
    inv.i_plant_attr_00 AS i_plant_attr_00 WITH SYNONYMS = ('plant', 'plant code') COMMENT = 'Inventory attribute i_plant_attr_00. Represents the plant classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_region_attr_01 AS i_region_attr_01 WITH SYNONYMS = ('region', 'region code') COMMENT = 'Inventory attribute i_region_attr_01. Represents the region classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_business_unit_attr_02 AS i_business_unit_attr_02 WITH SYNONYMS = ('business unit', 'business_unit code') COMMENT = 'Inventory attribute i_business_unit_attr_02. Represents the business unit classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_commodity_attr_03 AS i_commodity_attr_03 WITH SYNONYMS = ('commodity', 'commodity code') COMMENT = 'Inventory attribute i_commodity_attr_03. Represents the commodity classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_supplier_tier_attr_04 AS i_supplier_tier_attr_04 WITH SYNONYMS = ('supplier tier', 'supplier_tier code') COMMENT = 'Inventory attribute i_supplier_tier_attr_04. Represents the supplier tier classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_incoterm_attr_05 AS i_incoterm_attr_05 WITH SYNONYMS = ('incoterm', 'incoterm code') COMMENT = 'Inventory attribute i_incoterm_attr_05. Represents the incoterm classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_channel_attr_06 AS i_channel_attr_06 WITH SYNONYMS = ('channel', 'channel code') COMMENT = 'Inventory attribute i_channel_attr_06. Represents the channel classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_segment_attr_07 AS i_segment_attr_07 WITH SYNONYMS = ('segment', 'segment code') COMMENT = 'Inventory attribute i_segment_attr_07. Represents the segment classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_program_attr_08 AS i_program_attr_08 WITH SYNONYMS = ('program', 'program code') COMMENT = 'Inventory attribute i_program_attr_08. Represents the program classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_platform_attr_09 AS i_platform_attr_09 WITH SYNONYMS = ('platform', 'platform code') COMMENT = 'Inventory attribute i_platform_attr_09. Represents the platform classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_connector_family_attr_10 AS i_connector_family_attr_10 WITH SYNONYMS = ('connector family', 'connector_family code') COMMENT = 'Inventory attribute i_connector_family_attr_10. Represents the connector family classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_pin_count_attr_11 AS i_pin_count_attr_11 WITH SYNONYMS = ('pin count', 'pin_count code') COMMENT = 'Inventory attribute i_pin_count_attr_11. Represents the pin count classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_material_attr_12 AS i_material_attr_12 WITH SYNONYMS = ('material', 'material code') COMMENT = 'Inventory attribute i_material_attr_12. Represents the material classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_plating_attr_13 AS i_plating_attr_13 WITH SYNONYMS = ('plating', 'plating code') COMMENT = 'Inventory attribute i_plating_attr_13. Represents the plating classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_currency_attr_14 AS i_currency_attr_14 WITH SYNONYMS = ('currency', 'currency code') COMMENT = 'Inventory attribute i_currency_attr_14. Represents the currency classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_fiscal_period_attr_15 AS i_fiscal_period_attr_15 WITH SYNONYMS = ('fiscal period', 'fiscal_period code') COMMENT = 'Inventory attribute i_fiscal_period_attr_15. Represents the fiscal period classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_planner_attr_16 AS i_planner_attr_16 WITH SYNONYMS = ('planner', 'planner code') COMMENT = 'Inventory attribute i_planner_attr_16. Represents the planner classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_buyer_attr_17 AS i_buyer_attr_17 WITH SYNONYMS = ('buyer', 'buyer code') COMMENT = 'Inventory attribute i_buyer_attr_17. Represents the buyer classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_warehouse_zone_attr_18 AS i_warehouse_zone_attr_18 WITH SYNONYMS = ('warehouse zone', 'warehouse_zone code') COMMENT = 'Inventory attribute i_warehouse_zone_attr_18. Represents the warehouse zone classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_lot_class_attr_19 AS i_lot_class_attr_19 WITH SYNONYMS = ('lot class', 'lot_class code') COMMENT = 'Inventory attribute i_lot_class_attr_19. Represents the lot class classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_plant_attr_20 AS i_plant_attr_20 WITH SYNONYMS = ('plant', 'plant code') COMMENT = 'Inventory attribute i_plant_attr_20. Represents the plant classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_region_attr_21 AS i_region_attr_21 WITH SYNONYMS = ('region', 'region code') COMMENT = 'Inventory attribute i_region_attr_21. Represents the region classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_business_unit_attr_22 AS i_business_unit_attr_22 WITH SYNONYMS = ('business unit', 'business_unit code') COMMENT = 'Inventory attribute i_business_unit_attr_22. Represents the business unit classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_commodity_attr_23 AS i_commodity_attr_23 WITH SYNONYMS = ('commodity', 'commodity code') COMMENT = 'Inventory attribute i_commodity_attr_23. Represents the commodity classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_supplier_tier_attr_24 AS i_supplier_tier_attr_24 WITH SYNONYMS = ('supplier tier', 'supplier_tier code') COMMENT = 'Inventory attribute i_supplier_tier_attr_24. Represents the supplier tier classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_incoterm_attr_25 AS i_incoterm_attr_25 WITH SYNONYMS = ('incoterm', 'incoterm code') COMMENT = 'Inventory attribute i_incoterm_attr_25. Represents the incoterm classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_channel_attr_26 AS i_channel_attr_26 WITH SYNONYMS = ('channel', 'channel code') COMMENT = 'Inventory attribute i_channel_attr_26. Represents the channel classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_segment_attr_27 AS i_segment_attr_27 WITH SYNONYMS = ('segment', 'segment code') COMMENT = 'Inventory attribute i_segment_attr_27. Represents the segment classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_program_attr_28 AS i_program_attr_28 WITH SYNONYMS = ('program', 'program code') COMMENT = 'Inventory attribute i_program_attr_28. Represents the program classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_platform_attr_29 AS i_platform_attr_29 WITH SYNONYMS = ('platform', 'platform code') COMMENT = 'Inventory attribute i_platform_attr_29. Represents the platform classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_connector_family_attr_30 AS i_connector_family_attr_30 WITH SYNONYMS = ('connector family', 'connector_family code') COMMENT = 'Inventory attribute i_connector_family_attr_30. Represents the connector family classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_pin_count_attr_31 AS i_pin_count_attr_31 WITH SYNONYMS = ('pin count', 'pin_count code') COMMENT = 'Inventory attribute i_pin_count_attr_31. Represents the pin count classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_material_attr_32 AS i_material_attr_32 WITH SYNONYMS = ('material', 'material code') COMMENT = 'Inventory attribute i_material_attr_32. Represents the material classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_plating_attr_33 AS i_plating_attr_33 WITH SYNONYMS = ('plating', 'plating code') COMMENT = 'Inventory attribute i_plating_attr_33. Represents the plating classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_currency_attr_34 AS i_currency_attr_34 WITH SYNONYMS = ('currency', 'currency code') COMMENT = 'Inventory attribute i_currency_attr_34. Represents the currency classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_fiscal_period_attr_35 AS i_fiscal_period_attr_35 WITH SYNONYMS = ('fiscal period', 'fiscal_period code') COMMENT = 'Inventory attribute i_fiscal_period_attr_35. Represents the fiscal period classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_planner_attr_36 AS i_planner_attr_36 WITH SYNONYMS = ('planner', 'planner code') COMMENT = 'Inventory attribute i_planner_attr_36. Represents the planner classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_buyer_attr_37 AS i_buyer_attr_37 WITH SYNONYMS = ('buyer', 'buyer code') COMMENT = 'Inventory attribute i_buyer_attr_37. Represents the buyer classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_warehouse_zone_attr_38 AS i_warehouse_zone_attr_38 WITH SYNONYMS = ('warehouse zone', 'warehouse_zone code') COMMENT = 'Inventory attribute i_warehouse_zone_attr_38. Represents the warehouse zone classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_lot_class_attr_39 AS i_lot_class_attr_39 WITH SYNONYMS = ('lot class', 'lot_class code') COMMENT = 'Inventory attribute i_lot_class_attr_39. Represents the lot class classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_plant_attr_40 AS i_plant_attr_40 WITH SYNONYMS = ('plant', 'plant code') COMMENT = 'Inventory attribute i_plant_attr_40. Represents the plant classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_region_attr_41 AS i_region_attr_41 WITH SYNONYMS = ('region', 'region code') COMMENT = 'Inventory attribute i_region_attr_41. Represents the region classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_business_unit_attr_42 AS i_business_unit_attr_42 WITH SYNONYMS = ('business unit', 'business_unit code') COMMENT = 'Inventory attribute i_business_unit_attr_42. Represents the business unit classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_commodity_attr_43 AS i_commodity_attr_43 WITH SYNONYMS = ('commodity', 'commodity code') COMMENT = 'Inventory attribute i_commodity_attr_43. Represents the commodity classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_supplier_tier_attr_44 AS i_supplier_tier_attr_44 WITH SYNONYMS = ('supplier tier', 'supplier_tier code') COMMENT = 'Inventory attribute i_supplier_tier_attr_44. Represents the supplier tier classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_incoterm_attr_45 AS i_incoterm_attr_45 WITH SYNONYMS = ('incoterm', 'incoterm code') COMMENT = 'Inventory attribute i_incoterm_attr_45. Represents the incoterm classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_channel_attr_46 AS i_channel_attr_46 WITH SYNONYMS = ('channel', 'channel code') COMMENT = 'Inventory attribute i_channel_attr_46. Represents the channel classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_segment_attr_47 AS i_segment_attr_47 WITH SYNONYMS = ('segment', 'segment code') COMMENT = 'Inventory attribute i_segment_attr_47. Represents the segment classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_program_attr_48 AS i_program_attr_48 WITH SYNONYMS = ('program', 'program code') COMMENT = 'Inventory attribute i_program_attr_48. Represents the program classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_platform_attr_49 AS i_platform_attr_49 WITH SYNONYMS = ('platform', 'platform code') COMMENT = 'Inventory attribute i_platform_attr_49. Represents the platform classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_connector_family_attr_50 AS i_connector_family_attr_50 WITH SYNONYMS = ('connector family', 'connector_family code') COMMENT = 'Inventory attribute i_connector_family_attr_50. Represents the connector family classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_pin_count_attr_51 AS i_pin_count_attr_51 WITH SYNONYMS = ('pin count', 'pin_count code') COMMENT = 'Inventory attribute i_pin_count_attr_51. Represents the pin count classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_material_attr_52 AS i_material_attr_52 WITH SYNONYMS = ('material', 'material code') COMMENT = 'Inventory attribute i_material_attr_52. Represents the material classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_plating_attr_53 AS i_plating_attr_53 WITH SYNONYMS = ('plating', 'plating code') COMMENT = 'Inventory attribute i_plating_attr_53. Represents the plating classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_currency_attr_54 AS i_currency_attr_54 WITH SYNONYMS = ('currency', 'currency code') COMMENT = 'Inventory attribute i_currency_attr_54. Represents the currency classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_fiscal_period_attr_55 AS i_fiscal_period_attr_55 WITH SYNONYMS = ('fiscal period', 'fiscal_period code') COMMENT = 'Inventory attribute i_fiscal_period_attr_55. Represents the fiscal period classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_planner_attr_56 AS i_planner_attr_56 WITH SYNONYMS = ('planner', 'planner code') COMMENT = 'Inventory attribute i_planner_attr_56. Represents the planner classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_buyer_attr_57 AS i_buyer_attr_57 WITH SYNONYMS = ('buyer', 'buyer code') COMMENT = 'Inventory attribute i_buyer_attr_57. Represents the buyer classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_warehouse_zone_attr_58 AS i_warehouse_zone_attr_58 WITH SYNONYMS = ('warehouse zone', 'warehouse_zone code') COMMENT = 'Inventory attribute i_warehouse_zone_attr_58. Represents the warehouse zone classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_lot_class_attr_59 AS i_lot_class_attr_59 WITH SYNONYMS = ('lot class', 'lot_class code') COMMENT = 'Inventory attribute i_lot_class_attr_59. Represents the lot class classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_plant_attr_60 AS i_plant_attr_60 WITH SYNONYMS = ('plant', 'plant code') COMMENT = 'Inventory attribute i_plant_attr_60. Represents the plant classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_region_attr_61 AS i_region_attr_61 WITH SYNONYMS = ('region', 'region code') COMMENT = 'Inventory attribute i_region_attr_61. Represents the region classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_business_unit_attr_62 AS i_business_unit_attr_62 WITH SYNONYMS = ('business unit', 'business_unit code') COMMENT = 'Inventory attribute i_business_unit_attr_62. Represents the business unit classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_commodity_attr_63 AS i_commodity_attr_63 WITH SYNONYMS = ('commodity', 'commodity code') COMMENT = 'Inventory attribute i_commodity_attr_63. Represents the commodity classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_supplier_tier_attr_64 AS i_supplier_tier_attr_64 WITH SYNONYMS = ('supplier tier', 'supplier_tier code') COMMENT = 'Inventory attribute i_supplier_tier_attr_64. Represents the supplier tier classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_incoterm_attr_65 AS i_incoterm_attr_65 WITH SYNONYMS = ('incoterm', 'incoterm code') COMMENT = 'Inventory attribute i_incoterm_attr_65. Represents the incoterm classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_channel_attr_66 AS i_channel_attr_66 WITH SYNONYMS = ('channel', 'channel code') COMMENT = 'Inventory attribute i_channel_attr_66. Represents the channel classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_segment_attr_67 AS i_segment_attr_67 WITH SYNONYMS = ('segment', 'segment code') COMMENT = 'Inventory attribute i_segment_attr_67. Represents the segment classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_program_attr_68 AS i_program_attr_68 WITH SYNONYMS = ('program', 'program code') COMMENT = 'Inventory attribute i_program_attr_68. Represents the program classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_platform_attr_69 AS i_platform_attr_69 WITH SYNONYMS = ('platform', 'platform code') COMMENT = 'Inventory attribute i_platform_attr_69. Represents the platform classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_connector_family_attr_70 AS i_connector_family_attr_70 WITH SYNONYMS = ('connector family', 'connector_family code') COMMENT = 'Inventory attribute i_connector_family_attr_70. Represents the connector family classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_pin_count_attr_71 AS i_pin_count_attr_71 WITH SYNONYMS = ('pin count', 'pin_count code') COMMENT = 'Inventory attribute i_pin_count_attr_71. Represents the pin count classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_material_attr_72 AS i_material_attr_72 WITH SYNONYMS = ('material', 'material code') COMMENT = 'Inventory attribute i_material_attr_72. Represents the material classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_plating_attr_73 AS i_plating_attr_73 WITH SYNONYMS = ('plating', 'plating code') COMMENT = 'Inventory attribute i_plating_attr_73. Represents the plating classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_currency_attr_74 AS i_currency_attr_74 WITH SYNONYMS = ('currency', 'currency code') COMMENT = 'Inventory attribute i_currency_attr_74. Represents the currency classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_fiscal_period_attr_75 AS i_fiscal_period_attr_75 WITH SYNONYMS = ('fiscal period', 'fiscal_period code') COMMENT = 'Inventory attribute i_fiscal_period_attr_75. Represents the fiscal period classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_planner_attr_76 AS i_planner_attr_76 WITH SYNONYMS = ('planner', 'planner code') COMMENT = 'Inventory attribute i_planner_attr_76. Represents the planner classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_buyer_attr_77 AS i_buyer_attr_77 WITH SYNONYMS = ('buyer', 'buyer code') COMMENT = 'Inventory attribute i_buyer_attr_77. Represents the buyer classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_warehouse_zone_attr_78 AS i_warehouse_zone_attr_78 WITH SYNONYMS = ('warehouse zone', 'warehouse_zone code') COMMENT = 'Inventory attribute i_warehouse_zone_attr_78. Represents the warehouse zone classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_lot_class_attr_79 AS i_lot_class_attr_79 WITH SYNONYMS = ('lot class', 'lot_class code') COMMENT = 'Inventory attribute i_lot_class_attr_79. Represents the lot class classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_plant_attr_80 AS i_plant_attr_80 WITH SYNONYMS = ('plant', 'plant code') COMMENT = 'Inventory attribute i_plant_attr_80. Represents the plant classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_region_attr_81 AS i_region_attr_81 WITH SYNONYMS = ('region', 'region code') COMMENT = 'Inventory attribute i_region_attr_81. Represents the region classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_business_unit_attr_82 AS i_business_unit_attr_82 WITH SYNONYMS = ('business unit', 'business_unit code') COMMENT = 'Inventory attribute i_business_unit_attr_82. Represents the business unit classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_commodity_attr_83 AS i_commodity_attr_83 WITH SYNONYMS = ('commodity', 'commodity code') COMMENT = 'Inventory attribute i_commodity_attr_83. Represents the commodity classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_supplier_tier_attr_84 AS i_supplier_tier_attr_84 WITH SYNONYMS = ('supplier tier', 'supplier_tier code') COMMENT = 'Inventory attribute i_supplier_tier_attr_84. Represents the supplier tier classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_incoterm_attr_85 AS i_incoterm_attr_85 WITH SYNONYMS = ('incoterm', 'incoterm code') COMMENT = 'Inventory attribute i_incoterm_attr_85. Represents the incoterm classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_channel_attr_86 AS i_channel_attr_86 WITH SYNONYMS = ('channel', 'channel code') COMMENT = 'Inventory attribute i_channel_attr_86. Represents the channel classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_segment_attr_87 AS i_segment_attr_87 WITH SYNONYMS = ('segment', 'segment code') COMMENT = 'Inventory attribute i_segment_attr_87. Represents the segment classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_program_attr_88 AS i_program_attr_88 WITH SYNONYMS = ('program', 'program code') COMMENT = 'Inventory attribute i_program_attr_88. Represents the program classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_platform_attr_89 AS i_platform_attr_89 WITH SYNONYMS = ('platform', 'platform code') COMMENT = 'Inventory attribute i_platform_attr_89. Represents the platform classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_connector_family_attr_90 AS i_connector_family_attr_90 WITH SYNONYMS = ('connector family', 'connector_family code') COMMENT = 'Inventory attribute i_connector_family_attr_90. Represents the connector family classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_pin_count_attr_91 AS i_pin_count_attr_91 WITH SYNONYMS = ('pin count', 'pin_count code') COMMENT = 'Inventory attribute i_pin_count_attr_91. Represents the pin count classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_material_attr_92 AS i_material_attr_92 WITH SYNONYMS = ('material', 'material code') COMMENT = 'Inventory attribute i_material_attr_92. Represents the material classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_plating_attr_93 AS i_plating_attr_93 WITH SYNONYMS = ('plating', 'plating code') COMMENT = 'Inventory attribute i_plating_attr_93. Represents the plating classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_currency_attr_94 AS i_currency_attr_94 WITH SYNONYMS = ('currency', 'currency code') COMMENT = 'Inventory attribute i_currency_attr_94. Represents the currency classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_fiscal_period_attr_95 AS i_fiscal_period_attr_95 WITH SYNONYMS = ('fiscal period', 'fiscal_period code') COMMENT = 'Inventory attribute i_fiscal_period_attr_95. Represents the fiscal period classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_planner_attr_96 AS i_planner_attr_96 WITH SYNONYMS = ('planner', 'planner code') COMMENT = 'Inventory attribute i_planner_attr_96. Represents the planner classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_buyer_attr_97 AS i_buyer_attr_97 WITH SYNONYMS = ('buyer', 'buyer code') COMMENT = 'Inventory attribute i_buyer_attr_97. Represents the buyer classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_warehouse_zone_attr_98 AS i_warehouse_zone_attr_98 WITH SYNONYMS = ('warehouse zone', 'warehouse_zone code') COMMENT = 'Inventory attribute i_warehouse_zone_attr_98. Represents the warehouse zone classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_lot_class_attr_99 AS i_lot_class_attr_99 WITH SYNONYMS = ('lot class', 'lot_class code') COMMENT = 'Inventory attribute i_lot_class_attr_99. Represents the lot class classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_plant_attr_100 AS i_plant_attr_100 WITH SYNONYMS = ('plant', 'plant code') COMMENT = 'Inventory attribute i_plant_attr_100. Represents the plant classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_region_attr_101 AS i_region_attr_101 WITH SYNONYMS = ('region', 'region code') COMMENT = 'Inventory attribute i_region_attr_101. Represents the region classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_business_unit_attr_102 AS i_business_unit_attr_102 WITH SYNONYMS = ('business unit', 'business_unit code') COMMENT = 'Inventory attribute i_business_unit_attr_102. Represents the business unit classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_commodity_attr_103 AS i_commodity_attr_103 WITH SYNONYMS = ('commodity', 'commodity code') COMMENT = 'Inventory attribute i_commodity_attr_103. Represents the commodity classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_supplier_tier_attr_104 AS i_supplier_tier_attr_104 WITH SYNONYMS = ('supplier tier', 'supplier_tier code') COMMENT = 'Inventory attribute i_supplier_tier_attr_104. Represents the supplier tier classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_incoterm_attr_105 AS i_incoterm_attr_105 WITH SYNONYMS = ('incoterm', 'incoterm code') COMMENT = 'Inventory attribute i_incoterm_attr_105. Represents the incoterm classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_channel_attr_106 AS i_channel_attr_106 WITH SYNONYMS = ('channel', 'channel code') COMMENT = 'Inventory attribute i_channel_attr_106. Represents the channel classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_segment_attr_107 AS i_segment_attr_107 WITH SYNONYMS = ('segment', 'segment code') COMMENT = 'Inventory attribute i_segment_attr_107. Represents the segment classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_program_attr_108 AS i_program_attr_108 WITH SYNONYMS = ('program', 'program code') COMMENT = 'Inventory attribute i_program_attr_108. Represents the program classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_platform_attr_109 AS i_platform_attr_109 WITH SYNONYMS = ('platform', 'platform code') COMMENT = 'Inventory attribute i_platform_attr_109. Represents the platform classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_connector_family_attr_110 AS i_connector_family_attr_110 WITH SYNONYMS = ('connector family', 'connector_family code') COMMENT = 'Inventory attribute i_connector_family_attr_110. Represents the connector family classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_pin_count_attr_111 AS i_pin_count_attr_111 WITH SYNONYMS = ('pin count', 'pin_count code') COMMENT = 'Inventory attribute i_pin_count_attr_111. Represents the pin count classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_material_attr_112 AS i_material_attr_112 WITH SYNONYMS = ('material', 'material code') COMMENT = 'Inventory attribute i_material_attr_112. Represents the material classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_plating_attr_113 AS i_plating_attr_113 WITH SYNONYMS = ('plating', 'plating code') COMMENT = 'Inventory attribute i_plating_attr_113. Represents the plating classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_currency_attr_114 AS i_currency_attr_114 WITH SYNONYMS = ('currency', 'currency code') COMMENT = 'Inventory attribute i_currency_attr_114. Represents the currency classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_fiscal_period_attr_115 AS i_fiscal_period_attr_115 WITH SYNONYMS = ('fiscal period', 'fiscal_period code') COMMENT = 'Inventory attribute i_fiscal_period_attr_115. Represents the fiscal period classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_planner_attr_116 AS i_planner_attr_116 WITH SYNONYMS = ('planner', 'planner code') COMMENT = 'Inventory attribute i_planner_attr_116. Represents the planner classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_buyer_attr_117 AS i_buyer_attr_117 WITH SYNONYMS = ('buyer', 'buyer code') COMMENT = 'Inventory attribute i_buyer_attr_117. Represents the buyer classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_warehouse_zone_attr_118 AS i_warehouse_zone_attr_118 WITH SYNONYMS = ('warehouse zone', 'warehouse_zone code') COMMENT = 'Inventory attribute i_warehouse_zone_attr_118. Represents the warehouse zone classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.',
    inv.i_lot_class_attr_119 AS i_lot_class_attr_119 WITH SYNONYMS = ('lot class', 'lot_class code') COMMENT = 'Inventory attribute i_lot_class_attr_119. Represents the lot class classification used by the Inventory reporting team for slicing KPIs. Values are conformed against the enterprise master data hub, refreshed nightly, and may be blank for legacy records created before the 2019 ERP migration. Use for grouping and filtering only; do not aggregate.'
  )
  METRICS (
    inv.total_on_hand AS SUM(inv.on_hand_qty) COMMENT = 'Total on-hand units',
    inv.total_inventory_value AS SUM(inv.inventory_value) COMMENT = 'Total inventory value USD',
    inv.total_safety_stock AS SUM(inv.safety_stock_qty) COMMENT = 'Total safety stock units'
  )
  COMMENT = 'Inventory semantic view for the A2A benchmark';

CREATE OR REPLACE AGENT MULTIAGENT_DEMO.BENCH.SALES_AGENT
  FROM SPECIFICATION $$
models:
  orchestration: claude-sonnet-4-6
instructions:
  response: "Be concise. Return the result table and a chart when the answer has more than one row."
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: query_sales
      description: "Sales orders, revenue, units by product, region, date"
  - tool_spec:
      type: data_to_chart
      name: data_to_chart
      description: "Generate a chart from query results"
tool_resources:
  query_sales:
    semantic_view: MULTIAGENT_DEMO.BENCH.SALES_SV
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
$$;

CREATE OR REPLACE AGENT MULTIAGENT_DEMO.BENCH.INVENTORY_AGENT
  FROM SPECIFICATION $$
models:
  orchestration: claude-sonnet-4-6
instructions:
  response: "Be concise. Return the result table and a chart when the answer has more than one row."
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: query_inventory
      description: "Inventory on hand, safety stock, value by product, plant, date"
  - tool_spec:
      type: data_to_chart
      name: data_to_chart
      description: "Generate a chart from query results"
tool_resources:
  query_inventory:
    semantic_view: MULTIAGENT_DEMO.BENCH.INVENTORY_SV
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
$$;

CREATE OR REPLACE AGENT MULTIAGENT_DEMO.BENCH.SINGLE_AGENT
  FROM SPECIFICATION $$
models:
  orchestration: claude-sonnet-4-6
instructions:
  response: "Be concise. Return the result table and a chart when the answer has more than one row."
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: query_sales
      description: "Sales orders, revenue, units by product, region, date"
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: query_inventory
      description: "Inventory on hand, safety stock, value by product, plant, date"
  - tool_spec:
      type: data_to_chart
      name: data_to_chart
      description: "Generate a chart from query results"
tool_resources:
  query_sales:
    semantic_view: MULTIAGENT_DEMO.BENCH.SALES_SV
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
  query_inventory:
    semantic_view: MULTIAGENT_DEMO.BENCH.INVENTORY_SV
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
$$;

CREATE OR REPLACE AGENT MULTIAGENT_DEMO.BENCH.MASTER_TOOLSET_AGENT
  FROM SPECIFICATION $$
models:
  orchestration: claude-sonnet-4-6
instructions:
  response: "Be concise. Return the result table and a chart when the answer has more than one row."
tools:
  - tool_spec:
      type: agent_toolset
      name: sales_toolset
  - tool_spec:
      type: agent_toolset
      name: inventory_toolset
tool_resources:
  sales_toolset:
    agent_name: MULTIAGENT_DEMO.BENCH.SALES_AGENT
  inventory_toolset:
    agent_name: MULTIAGENT_DEMO.BENCH.INVENTORY_AGENT
$$;

CREATE OR REPLACE MCP SERVER MULTIAGENT_DEMO.BENCH.BENCH_MCP FROM SPECIFICATION $$
tools:
  - name: "sales_agent"
    type: "CORTEX_AGENT_RUN"
    identifier: "MULTIAGENT_DEMO.BENCH.SALES_AGENT"
    title: "Sales agent"
    description: "Answers sales questions: revenue, units, orders by product/region/date"
  - name: "inventory_agent"
    type: "CORTEX_AGENT_RUN"
    identifier: "MULTIAGENT_DEMO.BENCH.INVENTORY_AGENT"
    title: "Inventory agent"
    description: "Answers inventory questions: on hand, safety stock, value by product/plant/date"
$$;

-- "Before" pattern: sub-agents wrapped in DATA_AGENT_RUN stored procedures (text-only return),
-- attached to a master agent as custom tools. Usage is logged so sub-agent tokens can be measured;
-- the master still only sees the text, exactly like the original demo.

CREATE TABLE IF NOT EXISTS SUBAGENT_USAGE_LOG (
  logged_at TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP(), agent STRING, run_tag STRING, usage VARIANT);
CREATE OR REPLACE PROCEDURE CALL_SALES_AGENT(QUERY STRING)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    full_result STRING;
    text_result STRING;
    request_json STRING;
BEGIN
    SELECT OBJECT_CONSTRUCT('messages', ARRAY_CONSTRUCT(OBJECT_CONSTRUCT('role', 'user',
             'content', ARRAY_CONSTRUCT(OBJECT_CONSTRUCT('type', 'text', 'text', :query)))))::STRING
      INTO :request_json;
    SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN('MULTIAGENT_DEMO.BENCH.SALES_AGENT', :request_json)
      INTO :full_result;
    INSERT INTO MULTIAGENT_DEMO.BENCH.SUBAGENT_USAGE_LOG (agent, run_tag, usage)
      SELECT 'SALES_AGENT', CURRENT_QUERY_TAG(), PARSE_JSON(:full_result):metadata:usage;
    SELECT LISTAGG(value:text::STRING, '') WITHIN GROUP (ORDER BY index) INTO :text_result
      FROM TABLE(FLATTEN(INPUT => PARSE_JSON(:full_result):content)) WHERE value:type = 'text';
    RETURN COALESCE(NULLIF(:text_result, ''), :full_result);
END;
$$;
CREATE OR REPLACE PROCEDURE CALL_INVENTORY_AGENT(QUERY STRING)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    full_result STRING;
    text_result STRING;
    request_json STRING;
BEGIN
    SELECT OBJECT_CONSTRUCT('messages', ARRAY_CONSTRUCT(OBJECT_CONSTRUCT('role', 'user',
             'content', ARRAY_CONSTRUCT(OBJECT_CONSTRUCT('type', 'text', 'text', :query)))))::STRING
      INTO :request_json;
    SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN('MULTIAGENT_DEMO.BENCH.INVENTORY_AGENT', :request_json)
      INTO :full_result;
    INSERT INTO MULTIAGENT_DEMO.BENCH.SUBAGENT_USAGE_LOG (agent, run_tag, usage)
      SELECT 'INVENTORY_AGENT', CURRENT_QUERY_TAG(), PARSE_JSON(:full_result):metadata:usage;
    SELECT LISTAGG(value:text::STRING, '') WITHIN GROUP (ORDER BY index) INTO :text_result
      FROM TABLE(FLATTEN(INPUT => PARSE_JSON(:full_result):content)) WHERE value:type = 'text';
    RETURN COALESCE(NULLIF(:text_result, ''), :full_result);
END;
$$;
CREATE OR REPLACE AGENT MULTIAGENT_DEMO.BENCH.MASTER_SPROC_AGENT
  FROM SPECIFICATION $$
models:
  orchestration: claude-sonnet-4-6
instructions:
  response: "Be concise. Return the result table and a chart when the answer has more than one row."
tools:
  - tool_spec:
      type: generic
      name: call_sales_agent
      description: "Ask the sales agent: sales orders, revenue, units by product, region, date"
      input_schema:
        type: object
        properties:
          query:
            type: string
            description: "Natural-language question for the sales agent"
        required: [query]
  - tool_spec:
      type: generic
      name: call_inventory_agent
      description: "Ask the inventory agent: on hand, safety stock, value by product, plant, date"
      input_schema:
        type: object
        properties:
          query:
            type: string
            description: "Natural-language question for the inventory agent"
        required: [query]
  - tool_spec:
      type: data_to_chart
      name: data_to_chart
      description: "Generate a chart from data"
tool_resources:
  call_sales_agent:
    type: procedure
    identifier: MULTIAGENT_DEMO.BENCH.CALL_SALES_AGENT
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
  call_inventory_agent:
    type: procedure
    identifier: MULTIAGENT_DEMO.BENCH.CALL_INVENTORY_AGENT
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
$$;