-------------------------------------------------------------------------------
-- Quantum Projects Presents: Archaeology System for RedM
-- Version: 1.0.0
-- Author: Quantum Projects
-- Description: A fully customizable archaeology system for RedM servers.
--              Features archaeology sites, rewards, hubs, minigames, and an interactive book.
-- License: This script is for sale. Unauthorized distribution is strictly prohibited.
-- Contact: https://discord.gg/kJ8ZrGM8TS | Discord: artmines_playz
-------------------------------------------------------------------------------

Config = {}
-- Debug mode: Set to true to enable debugging features
Config.Debug = true

---------------------------------------------
-- General Settings
---------------------------------------------
Config.CoreFolderName = "rsg-core" -- Core folder name (DO NOT MODIFY)
Config.arcsiteCronJob  = '0 * * * *' -- Cron job schedule for archaeology sites (runs every hour at the 0th minute)
Config.arcsiteTime     = 1500 -- Time duration for archaeology site activities (in milliseconds)
Config.ServerNotify   = false -- Disables server Cron notifications when set to false
Config.RareItemChance = 5 -- 5% chance of finding a rare item
Config.ArchaeologyBrush = 'archeology_brush' -- Item required for archaeology sites

---------------------------------------------
-- Common Rewards
---------------------------------------------
-- List of common items players can find during archaeology activities
Config.CommonRewardItems = {
'finger_bone','bone_shards',
}
---------------------------------------------
-- Rare Rewards
---------------------------------------------
-- List of rare items with a lower chance of being found
Config.RareRewardItems = {
'arrowhead_bone', 'fossil_coral', 'fossil_pet_wood_rainbow',
}
---------------------------------------------
-- Archaeology Hubs
---------------------------------------------
-- Locations where players can interact with archaeology hubs
Config.ArchaeologyHubs = {
    { name = 'Archaeology Master', coords = vector3(338.67, 7.50, 106.18), showblip = true },
    { name = 'Archaeology Master', coords = vector3(2799.98, 1374.86, 71.31),   showblip = true },
}
---------------------------------------------
-- Archaeology Book
---------------------------------------------
-- Configuration for the archaeology book
Config.ItemBook = 'archeology_book' -- Item name for the archaeology book
Config.Book = {
    ['archeology_book'] = {  -- DON'T TOUCH UNLESS YOU KNOW WHAT YOU ARE DOING
        ['pages'] = {
            { pageName = "1", type = 'hard', source = 'local' }, --Front Cover
            { pageName = "2", type = 'hard', source = 'local' }, --Inside Front Cover
            { pageName = "3", type = 'normal', source = 'local' }, --
            { pageName = "4", type = 'normal', source = 'local' }, --
            { pageName = "5", type = 'normal', source = 'local' }, --
            { pageName = "6", type = 'normal', source = 'local' }, --
            { pageName = "7", type = 'normal', source = 'local' }, --
            { pageName = "8", type = 'normal', source = 'local' }, --
            { pageName = "9", type = 'normal', source = 'local' }, --
            { pageName = "10", type = 'normal', source = 'local' }, --
            { pageName = "11", type = 'normal', source = 'local' }, --
            { pageName = "12", type = 'normal', source = 'local' }, --
            { pageName = "13", type = 'normal', source = 'local' }, --
            { pageName = "14", type = 'normal', source = 'local' }, --
            { pageName = "15", type = 'normal', source = 'local' }, --
            { pageName = "16", type = 'normal', source = 'local' }, --
            { pageName = "17", type = 'normal', source = 'local' }, --
            { pageName = "18", type = 'normal', source = 'local' }, --
            { pageName = "19", type = 'normal', source = 'local' }, --
            { pageName = "20", type = 'normal', source = 'local' }, --
            { pageName = "21", type = 'normal', source = 'local' }, --
            { pageName = "22", type = 'normal', source = 'local' }, --
            { pageName = "23", type = 'normal', source = 'local' }, --
            { pageName = "24", type = 'normal', source = 'local' }, --
            { pageName = "25", type = 'normal', source = 'local' }, --
            { pageName = "26", type = 'normal', source = 'local' }, --
            { pageName = "27", type = 'normal', source = 'local' }, --
            { pageName = "28", type = 'normal', source = 'local' }, --
            { pageName = "29", type = 'hard', source = 'local' }, --Inside Rear Cover
            { pageName = "30", type = 'hard', source = 'local' }, --Rear Cover
        },
        ['prop'] = 'book', --ex. book, map
        ['size'] = { 
            ['width'] = 650, --page image width
            ['height'] = 750, --page image height
        },
    },
}
---------------------------------------------
-- Archaeology Sites
---------------------------------------------
-- Configuration for various archaeology sites with their details

Config.NoFossilItem = 'fossil_stone' --Item given when nothing is found

Config.ArcSites = {
    { -- Grassy Fields Dinosaur Bone
        arcid = 'Arch_Bone_03',
        coords = vector3(284.98, -436.31, 92.27), -- Coordinates of the site 
        IPL = -891504611, -- IPL identifier for the site
        item = 'fossil_trilobit', -- Item that can be found at this site
        chance = 23, -- Chance of finding the item
        givenpage = '4' -- Page number given for this site
    },
    { -- Heartlands South Gorge Bone
        arcid = 'Arch_Bone_24',  
        coords = vector3(441.34, -162.94, 119.24), -- 
        IPL = 1393010249,
        item = 'fossil_old',
        chance = 67,  
        givenpage = '5'
    },
    { -- Oil Derrick Dinosaur Bone
        arcid = 'Arch_Bone_00',  
        coords = vector3(366.25, -16.05, 99.15), --
        IPL = 1175400068,
        item = 'fossil_tooth_trex',
        chance = 13,  
        givenpage = '6'
    },
    { -- Heartlands Dewberry Creek Bone
        arcid = 'Arch_Bone_01',  
        coords = vector3(916.50, -241.26, 86.13), -- 
        IPL = 854689865,
        item = 'fossil_coral',
        chance = 97,  
        givenpage = '7'
    },
    { -- Scarlett Meadows Dewberry Creek Bone
        arcid = 'Arch_Bone_02',
        coords = vector3(862.06, -434.95, 82.26), -- 
        IPL = 1772877245,
        item = 'fossil_brachiopod',
        chance = 85,  
        givenpage = '8'
    },
    { -- Heartlands Abandoned Shack Bone
        arcid = 'Arch_Bone_07',  
        coords = vector3(1636.20, 807.11, 142.18), -- 
        IPL = -2054476413,
        item = 'fossil_tail_spike',
        chance = 42,  
        givenpage = '9'
    },
    { -- Roanoke Ridge Kamassa River Bone
        arcid = 'Arch_Bone_20',  
        coords = vector3(2343.73, 1101.26, 100.24), -- 
        IPL = 2119466214,
        item = 'fossil_tooth_serrated',
        chance = 30,  
        givenpage = '10'
    },
    { -- Roanoke Ridge Van Horn Bone
        arcid = 'Arch_Bone_21',  
        coords = vector3(2803.58, 728.35, 74.42), -- 
        IPL = 1812453453,
        item = 'dinosaur_egg',
        chance = 31,  
        givenpage = '11'
    },
    { -- Roanoke Ridge Valley Overlook Bone
        arcid = 'Arch_Bone_19',  
        coords = vector3(2788.99, 1841.52, 151.48), -- 
        IPL = 901975752,
        item = 'fossil_sea_lily',
        chance = 66,  
        givenpage = '12'
    },
    { -- Roanoke Ridge Overlook Bone 
        arcid = 'Arch_Bone_Myst1',  
        coords = vector3(2070.40, 1707.69, 163.39), -- 
        IPL = 203916786,
        item = 'fossil_pet_wood_yellow_cat',
        chance = 17,  
        givenpage = '13'
    },
    { -- Grizzlies Northern Boundary Bone
        arcid = 'Arch_Bone_Myst2',  
        coords = vector3(1592.95, 2037.40, 322.44), -- 
        IPL = 782453481,
        item = 'fossil_pet_wood_rainbow',
        chance = 61,  
        givenpage = '14'
    },
    { -- Grizzlies O'Creagh's Run Overlook Bone
        arcid = 'Arch_Bone_16',  
        coords = vector3(1351.16, 1449.85, 232.11), -- 
        IPL = 1988923494,
        item = 'fossil_pet_wood',
        chance = 82,  
        givenpage = '15'
    },
    { -- Grizzlies Calumet Ravine Bone
        arcid = 'Arch_Bone_Myst3',  
        coords = vector3(730.47, 2024.22, 258.33), -- 
        IPL = -1265903940,
        item = 'fossil_neo',
        chance = 9,  
        givenpage = '16'
    },
    { -- Bacchus Station Dinosaur Bone
        arcid = 'Arch_Bone_18',  
        coords = vector3(442.78, 1617.87, 206.53), -- 
        IPL = -1676256391,
        item = 'fossil_coral',
        chance = 15,  
        givenpage = '17'
    },
    { -- Grizzlies Dakota River Ledge Bone
        arcid = 'Arch_Bone_Myst4',  
        coords = vector3(150.53, 1585.05, 171.46), -- 
        IPL = -474761969,
        item = 'fossil_cephalopod',
        chance = 45,  
        givenpage = '18'
    },
    { -- Six Point Overlook Dinosaur Bone
        arcid = 'Arch_Bone_Myst5',  
        coords = vector3(-143.40, 1159.11, 160.75), -- 
        IPL = 104102416,
        item = 'fossil_brow_horn',
        chance = 31,  
        givenpage = '19'
    },
    { -- Grizzlies Rock Wall Bone
        arcid = 'Arch_Bone_05',  
        coords = vector3(-572.59, 957.43, 86.48), -- 
        IPL = -810270260,
        item = 'fossil_brachiopod',
        chance = 32,  
        givenpage = '20'
    },
    { -- Heartlands Northern Boundary Bone
        arcid = 'Arch_Bone_Myst6',  
        coords = vector3(-609.26, 853.68, 111.94), -- 
        IPL = 1891601353,
        item = 'fossil_bivalve',
        chance = 27,  
        givenpage = '21'
    },
    { -- Heartlands Cliff Face Bone
        arcid = 'Arch_Bone_06',  
        coords = vector3(-965.23, 122.02, 68.53), -- 
        IPL = 83602522,
        item = 'fossil_toe_claw',
        chance = 19,  
        givenpage = '22'
    },
    { -- Big Valley Northern Cave Bone
        arcid = 'Arch_Bone_Myst7',  
        coords = vector3(-1518.27, 743.37, 125.19),
        item = 'fossil_tooth_mega',
        chance = 5,  
        givenpage = '23'
    },
    { -- Big Valley Rocky Slope Bone
        arcid = 'Arch_Bone_Myst8',  
        coords = vector3(-2392.85, 325.83, 201.70),
        IPL = 1585258492,
        item = 'fossil_trilobite_crypto',
        chance = 5,  
        givenpage = '24'
    },
    { -- Big Valley Beryl's Dream Overlook Bone
        arcid = 'Arch_Bone_Myst9',  
        coords = vector3(-2314.13, -15.19, 255.55),
        IPL = 320262265,
        item = 'fossil_old',
        chance = 5,  
        givenpage = '25'
    },
    { -- Hennigan's Stead Pike's Basin Bone
        arcid = 'Arch_Bone_10',  
        coords = vector3(-3045.58, -2286.62, 47.58),
        IPL = 191871729,
        item = 'fossil_old',
        chance = 5,  
        givenpage = '26'
    },
    { -- Hennigan's Stead San Luis River Bone
        arcid = 'Arch_Bone_11',  
        coords = vector3(-2693.42, -3191.96, -7.87),
        IPL = -1078418763,
        item = 'fossil_old',
        chance = 5,  
        givenpage = '27'
    },
    { -- Rio Bravo Del Lobo Rock Bone
        arcid = 'Arch_Bone_26',  
        coords = vector3(-3571.25, -3605.22, 21.38),
        IPL = -415281478,
        item = 'fossil_old',
        chance =  5,  
        givenpage = '28'
    },
    { -- Cholla Springs Jorge's Gap Bone
        arcid = 'Arch_Bone_09',  
        coords = vector3(-4211.60, -2883.63, 11.04),
        IPL = -1434912930,
        item = 'fossil_old',
        chance = 5,  
        givenpage = '29'
    },
    { -- Cholla Springs High Desert Bone
        arcid = 'Arch_Bone_08',  
        coords = vector3(-4437.22, -2217.04, 40.15),
        IPL = 1934461192,
        item = 'fossil_old',
        chance = 5,  
        givenpage = ''
    },
    { -- Rio Bravo San Luis River Bone
        arcid = 'Arch_Bone_27',  
        coords = vector3(-4439.24, -3663.41, 57.23),
        IPL = -722949619,
        item = 'fossil_old',
        chance = 5,  
        givenpage = ''
    },
    { -- Gaptooth Ridge North Tumbleweed Bone
        arcid = 'Arch_Bone_28',  
        coords = vector3(-5279.74, -2692.40, 15.73),
        IPL = 202086482,
        item = 'fossil_old',
        chance = 5,  
        givenpage = ''
    },
    { -- Gaptooth Ridge South Tumbleweed Bone
        arcid = 'Arch_Bone_29',  
        coords = vector3(-5392.23, -3052.81, 11.93),
        IPL = -87394864,
        item = 'fossil_old',
        chance = 5,  
        givenpage = ''
    },
}

Config.ArcAdvancedSites = {
    { -- Mammoth
        arcid = 'Arc_Mammoth_01',
        jobarea = {
            [1] = {vector3(-1731.52, 2188.01, 291.41)},
            [2] = {vector3(-1733.75, 2191.42, 292.44)},
            [3] = {vector3(-1733.63, 2193.70, 292.86)},
            [4] = {vector3(-1731.45, 2193.05, 292.28)},
            [5] = {vector3(-1731.12, 2190.20, 291.76)},
        },
        experiance = 100,
        items = {'dinosaur_egg', 'fossil_bivalve'}
    },
    { -- Whale
        arcid = 'Arc_Whale_01',
        jobarea = {
            [1] = {vector3(-4681.54, -3414.76, 17.06)},
            [2] = {vector3(-4683.79, -3417.53, 16.85)},
            [3] = {vector3(-4686.80, -3419.32, 16.51)},
            [4] = {vector3(-4689.84, -3421.43, 16.23)},
            [5] = {vector3(-4688.83, -3418.69, 16.28)},
            [6] = {vector3(-4686.50, -3415.59, 16.52)},
        }, 
        experiance = 150,
        items = {'dinosaur_egg', 'fossil_bivalve'}
    },
}