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
** File: gps_util_lib.c
**
** Purpose:
**   Commonly used GPS utilties
**
*************************************************************************/

/*************************************************************************
** Includes
*************************************************************************/
#include "cfe.h"
#include "gps_util_lib.h"
#include "gps_util_version.h"

/*************************************************************************
** Macro Definitions
*************************************************************************/

/*************************************************************************
** Private Function Prototypes
*************************************************************************/
int32 GPS_UTIL_LibInit(void);

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                 */
/* Library Initialization Routine                                  */
/* cFE requires that a library have an initialization routine      */
/*                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
int32 GPS_UTIL_LibInit(void)
{
    OS_printf ("GPS_UTIL Lib Initialized. Version %d.%d.%d\n",
            GPS_UTIL_VERSION_MAJOR, GPS_UTIL_VERSION_MINOR, GPS_UTIL_VERSION_POINT);
    return CFE_SUCCESS;
} /* End GPS_UTIL_LibInit */

/* convert from DDDMM.mmmmm (decimal minutes) to DDD.dddddd (plain decimal) format */
double GPS_UTIL_dm2dd(const double decimal_minutes)
{
    double degrees = ((int) (decimal_minutes/100.0)); /* DDD        */ 
    double minutes = decimal_minutes - 100*degrees;   /* MM.mmmmmm  */ 
    double decimal = minutes / 60;                    /* 0.ddddddd  */ 
    return (degrees + decimal);                       /* DDD.dddddd */ 
} /* end GPS_UTIL_dm2dd */


/************************/
/*  End of File Comment */
/************************/
