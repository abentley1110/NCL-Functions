;******************************************************************************
; ut_string.ncl
; Carl Schreck (carl@atmos.albany.edu)
; Based on tTick by Arindam Chakrborty.
; Obtained from http://www.ncl.ucar.edu/Support/talk_archives/2007/0763.html
; September 2008
; Modified April 2009 by Carl Schreck (carl@atmos.albany.edu)
;   Replaced "mod" function call on line 279 with modulus operator %
;   Add default input string for ""
;******************************************************************************

undef("ut_string")

function ut_string( time[*]:numeric, inFormat:string )
;******************************************************************************
; Purpose: Convert a time into a string
;
; Arguments:
; time: The variable containing the values of time. This variable should
; have an attribute named "units". 
;
; inFormat: (OPTIONAL) a string specifying the format of the tick labels.
; This string is parsed as follows: the '%' acts as
; the escape character. The single character after every
; '%' is formatted according to the rule:
; Y => 4-digit year (e.g., 2007).
; y => 2-digit year (e.g., 07).
; C => CAPITAL month abbreviation (e.g., JUN).
; c => Small month abbreviation (e.g., Jun).
; F => CAPITAL full month (e.g., JUNE).
; f => Small full month (e.g., June).
; N => 2-digit month (e.g., 06).
; n => 1 or 2 digit month (e.g., 6 for June, 12 for December).
; D => 2-digit day (e.g., 04).
; d => 1 or 2 digit day (e.g., 4)
; H => 2-digit hour (e.g., 09).
; h => 1 or 2 digit hour (e.g., 9 or 11).
; M => 2 digit minute (e.g., 08).
; m => 1 or 2 digit minute (e.g., 07 or 56).
; S => 2 digit second (e.g., 02).
; s => 1 or 2 digit second (e.g., 2 or 23).
; Any character at any other place in the format string
; is drawn as is.
; NOTE: a '%' can be drawn using "%%".
; In case Format is absent, a minimal algorithm exists
; which tries to determine the format string depending
; on the length and values of the date-time.
;
; If inFormat is "", it will default to "%H%M UTC %d %c %Y"
; e.g., 1800 UTC 4 Jul 1776
;
; Return value:
;  a string represent the time(s) in the specified format
;
; Exmple 1:
;  timeDouble = ut_inv_calendar( 1776, 07, 04, 18, 00, 00,  "hours since 1800-01-01 00:00", 0 )
;  print( (/ ut_string( timeDouble, "" ) /) )
;  print( (/ ut_string( timeDouble, "%Y-%N-%D %H:%M:%S" ) /) )
;
;  The above will output:
; (0)     1800 UTC 4 Jul 1776
; (0)     1776-07-04 18:00:00
;
;******************************************************************************

local ymdhms0, ymdhms1i, chFormat, months, fmonths, inside, stFormat

begin

  if( inFormat.eq."" ) then
    stFormat = "%H%M UTC %d %c %Y"
  else
    stFormat = inFormat
  end if

  months = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
  fmonths = (/"","January","February","March","April","May","June","July","August","September","October","November","December"/)

  ; check input
  if (.not. isatt(time,"units")) then
    print("tTick: The variable containing time values must have a 'units' attribute.")
    return
  end if

  ymdhms0 = ut_calendar(time,0)
  nt = dimsizes(time)

  if (typeof(ymdhms0) .eq. "float") then
    ymdhms1i = floattointeger(ymdhms0)
  else
    ymdhms1i = ymdhms0
  end if
  taxisvalues = ut_inv_calendar(ymdhms1i(:,0),ymdhms1i(:,1),ymdhms1i(:,2),ymdhms1i(:,3),ymdhms1i(:,4),ymdhms1i(:,5),time@units,0)

  retVal = new(nt,"string")

  chFormat = stringtochar(stFormat)

  do i = 0, dimsizes(time)-1
    retVal(i) = ""
    inside = False
    j = 0
    do while(j .lt. dimsizes(chFormat))
      if (chFormat(j) .eq. "%") then
        inside = True
        j = j + 1
      end if

      if (.not. inside) then
        retVal(i) = retVal(i)+chFormat(j)
      else
        if (chFormat(j) .eq. "Y") then
          retVal(i) = retVal(i)+sprinti("%04d",ymdhms1i(i,0))
          inside = False
        end if
        if (chFormat(j) .eq. "y") then
          retVal(i) = retVal(i)+sprinti("%02d",ymdhms1i(i,0)%100)
          inside = False
        end if
        if (chFormat(j) .eq. "C") then
          retVal(i) = retVal(i)+changeCase(months(ymdhms1i(i,1)),"up")
          inside = False
        end if
        if (chFormat(j) .eq. "c") then
          retVal(i) = retVal(i)+months(ymdhms1i(i,1))
          inside = False
        end if
        if (chFormat(j) .eq. "F") then
          retVal(i) = retVal(i)+changeCase(fmonths(ymdhms1i(i,1)),"up")
          inside = False
        end if
        if (chFormat(j) .eq. "f") then
          retVal(i) = retVal(i)+fmonths(ymdhms1i(i,1))
          inside = False
        end if
        if (chFormat(j) .eq. "N") then
          retVal(i) = retVal(i)+sprinti("%02d",ymdhms1i(i,1))
          inside = False
        end if
        if (chFormat(j) .eq. "n") then
          retVal(i) = retVal(i)+sprinti("%d",ymdhms1i(i,1))
          inside = False
        end if
        if (chFormat(j) .eq. "D") then
          retVal(i) = retVal(i)+sprinti("%02d",ymdhms1i(i,2))
          inside = False
        end if
        if (chFormat(j) .eq. "d") then
          retVal(i) = retVal(i)+sprinti("%d",ymdhms1i(i,2))
          inside = False
        end if
        if (chFormat(j) .eq. "H") then
          retVal(i) = retVal(i)+sprinti("%02d",ymdhms1i(i,3))
          inside = False
        end if
        if (chFormat(j) .eq. "h") then
          retVal(i) = retVal(i)+sprinti("%d",ymdhms1i(i,3))
          inside = False
        end if
        if (chFormat(j) .eq. "M") then
          retVal(i) = retVal(i)+sprinti("%02d",ymdhms1i(i,4))
          inside = False
        end if
        if (chFormat(j) .eq. "m") then
          retVal(i) = retVal(i)+sprinti("%d",ymdhms1i(i,4))
          inside = False
        end if
        if (chFormat(j) .eq. "S") then
          retVal(i) = retVal(i)+sprinti("%02d",ymdhms1i(i,5))
          inside = False
        end if
        if (chFormat(j) .eq. "s") then
          retVal(i) = retVal(i)+sprinti("%d",ymdhms1i(i,5))
          inside = False
        end if
        if (chFormat(j) .eq. "%") then
          retVal(i) = retVal(i)+"%"
          inside = False
        end if
      end if

      j = j + 1
    end do

  end do

  return( retVal )
end 
