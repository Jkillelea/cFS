/*************************************************************************
**
**      GSC-18128-1, "Core Flight Executive Version 6.6"
**
**      Copyright (c) 2006-2019 United States Government as represented by
**      the Administrator of the National Aeronautics and Space Administration.
**      All Rights Reserved.
**
**      Licensed under the Apache License, Version 2.0 (the "License");
**      you may not use this file except in compliance with the License.
**      You may obtain a copy of the License at
**
**        http://www.apache.org/licenses/LICENSE-2.0
**
**      Unless required by applicable law or agreed to in writing, software
**      distributed under the License is distributed on an "AS IS" BASIS,
**      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
**      See the License for the specific language governing permissions and
**      limitations under the License.
**
** File: gps_util_lib.h
**
** Purpose: 
**   Commonly used GPS utilities
**
*************************************************************************/
#ifndef _GPS_UTIL_LIB_H_
#define _GPS_UTIL_LIB_H_

/************************************************************************
** Includes
*************************************************************************/
#include "cfe.h"

/************************************************************************
** Type Definitions
*************************************************************************/

/*************************************************************************
** Exported Functions
*************************************************************************/
/************************************************************************/
/** \brief GPS_UTIL_dm2dd
**  
**  \par Description
**        Converts between decimal minutes format and plain decimal format
**        Where decimal minutes format is a float in the form DDDMM.mmmm.
**        DDD    = decimal degrees, such as 122 degrees West
**        MM.mmm = minutes, such as 48.22 minutes, where a minute is 1/60th of a degree
**        Returns a float in the form DDD.dddddd, a raw decimal lattitude or longitude
**        Example (not real input/output) 122 degrees, 48.32' W -> 122.781232 degrees W
**
**  \par Assumptions, External Events, and Notes:
**        Performs no bounds checking on coordinates,
**        caller is responsible for checking that the input coordinate is a 
**        valid lattitude or longitde in the format DDDMMM.mmmmm.
**       
**  \returns
**  \retstmt Returns the coordinate as a double \endcode
**  \endreturns
** 
*************************************************************************/
double GPS_UTIL_dm2dd(const double decimal_minutes);

#endif /* _GPS_UTIL_LIB_H_ */

/************************/
/*  End of File Comment */
/************************/
