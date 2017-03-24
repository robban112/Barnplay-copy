//
//  Utils.swift
//  Barnplay
//
//  Created by John Wikman on 2016-03-17.
//  Copyright © 2015 OskarApps. All rights reserved.
//

// DDNDNNNNNNNNNNNNNNNNNNNNMNNNNO7+=~~~~::~~+OZDNMMMMNNDDNDNNDNNNMMMMMMMMMMMMMMMMMM
// DDDNDDDNDDNNNNNNNNNNNNNNMNNN87+=~~:::::::~+ZD8NMNNMMNNDNDNNNNNNNMMMMMMMMMMMMMMMM
// DDDNDNDDNNDNNDNNNNNNNNNMMMNDO?=~~~:::::::::ONONNNNMMNNNNDNNNNNNNMMMMMMMMMMMMMMMM
// DDDNDDNDNNNNNNNNNNNNDNMMMDN8$?=~~:~:::::,,:+O8NNNDNNNNNDD8NNNNNNNNMMMMMMMMMMMMMM
// DDDDDDDD8DD8DDNNNNNNNNMNNNDO7?+=~~~~~:::::::Z8DNNNNMMN8NNDNNNNNNNNNMMMMMMMMMMMMM
// DNDNNNNDDNDNNNNNNNNNNMMNMN887??=~~~~~~::::::$DDNDDDNNDNDDDDNNNNNNNNNNMMMMMMMMMMM
// NNNNNNNDNDDDNNDDNNNNNMMNDD887I?~~~:+~::::::::O8NNNNNDNNNDDDNDDNNNDNNNNNNMMMMMMMM
// DDDNDNDDDDDDNNDDDDNNMMMNND8O?+?+==~?~==I?$7I?ZODD88NNDDMNNDDNNNNDNDNNMMMMMMMMMMM
// DDDNDNNDDDDDNNNNNNNNMMMNND88Z88O8Z?~~7Z88?=:~I8DDMDNNDDNNMNDNNNDDNDNNNMMNMMMMMMM
// DDDDDNNDNDDDDDDNDDDMMMMNNDDM7IIO8DZ~:=?$I$ZNDD8ZNNMNNDNDNMMNDNDNNNDDNNMMNMMMMMMM
// 888DDDDDDDDDD8DNNNNMMMMNMNNNN$ND=Z$~::=~~==+~~77DNMMMNNDDNDNDDDNNDNDNNNNNMNMMMMM
// 888DDDDDDDDDDDDNNNNMMMMMMMND8$?+=$Z:::=~:~:,,:~+ZMNMMMMDDNDMDDDDDDD8NNNNNNMMMMMM
// 88888DDDDDDDDDDNNNDMMMMMMMNZ8?==?$Z=:~~~:::::,::=8MMMMMDNNMNDDDNDDDD8DNNDNNNNMMM
// 888888DD8DDDDDDDNNNMMMMMMMNO?+=~?$I~:~==:::::::~~IMMMMNDNNNDDD8D8DDNDNNDNDNMNMMM
// D888888D88D8DDDDNNNMMMMMMMM87+==IZ+~~,~~?:::,:~~==NMNMN8NNNN8DDDDDNNNDNNNDNNNMMM
// 8888888DD8DDDDD8DDDMNMMMMMMDOI++ZZZ~~=IO+?~::~~~~=8MMMMNNN8D8D88DDDNNDDNNNDNMMNM
// O88O8D88D8D888D888DNMMMMMMM8D$+IO$OD8+~=~:~~:~~~~~$MNNMNNDDND888DDDDNNDNNNNNNMNM
// DD8DDDDDDDDDDD8D888DMMMMMMMN8Z??777Z=I~::~:~~~~~~=IMMNMMMNDNDDD8DDNDDDNNNNDNNMMM
// D88DD8DDDDDDDDD888DDMMMMMMMM8Z???I?I~=~~~~=~~~~~~=?DNMMMMNDNDDDD8DDDDNNDDNDNNNMN
// DD8DDD8DDDDDDD888DDDNNMNMMMMN$=?77O8DODNO$I+~::~=??8NMMMMMDDNDD88DNDDDDDNDDNNNNN
// 8DDD8888DDDDDDDDD8DDNNNMMMMMMZ+=?7I7+==~~~~~=~~=+??ODMMMMMDNNDDDDDDDDDDDNDNDDNNN
// 8888888DDDDDDDD88888DNDMMMMMMOI+?$777Z$I+===~+==+?=88MMMMMONNDDDNDDDNNNNNNNNNNNN
// 888D8O8OOO8DDDD8DDD888NNMMMMMMOII+I7I=~~:=~:~~==?++.DNMMMD8DNDDDDNNDNDDNDNNNNNNN
// O888888888D888888OODDDNNNMMMMMMO$I===~~~:~:~~?I7?..MNNMMMMDDDDDMDNNDDDDDDDNNNMMN
// 8OOOOOOOO88888O888O88D8DMMMMMMMMD87+===+==++7I?+..MNNNMMMNNNNNDNNNNNNDDDDNDNNNNN
// 888OO8888O8888888D8D88DDDNMMMNNMMN8N8$$ZOD$7?..:DMNNNNMMNNNMNDDNNNDNNNDD8NDNNNNN
// OOO8OO88888888888888888DDMMMNNNNMMMMMM8DD=+=$NNDMNNNMMMNMMMNDDDDDNDNNMD88NDNNNNN
// O88O88888888O8DD88888DDDMDMMMNNDDNNMMMMMNNNNNNNMNNNMMMMMNNNNNM8DNN8DNM8OOO$NMNNN
// OODOOOO8OOD8O8888Z88ONDMMMMMMMMMMMNNNMNMMNNNNNMMNNNMMNNMNNNNNNNNNN8NNMD8ON8NMMNM

import Foundation

var GlobalMainQueue: dispatch_queue_t {
    return dispatch_get_main_queue()
}

var GlobalUserInteractiveQueue: dispatch_queue_t {
    return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
}

var GlobalUserInitiatedQueue: dispatch_queue_t {
    return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
}

var GlobalUtilityQueue: dispatch_queue_t {
    return dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
}

var GlobalBackgroundQueue: dispatch_queue_t {
    return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
}
