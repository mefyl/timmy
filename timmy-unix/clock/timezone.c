#include <assert.h>
#include <errno.h>
#include <time.h>

#include <caml/alloc.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>

#ifdef __MINGW32__
# include <timezoneapi.h>
#endif

static
void
check_tuple(value tuple, int size)
{
  assert(Is_block(tuple) && Tag_val(tuple) == 0 && Wosize_val(tuple) == size);
}

static
int
check_int(value n)
{
  assert(Is_long(n));
  return Int_val(n);
}

#ifndef __MINGW32__

static
int
offset(const time_t time, int* output)
{
  struct tm localtime;
  if (!localtime_r(&time, &localtime))
    return 0;
  *output = localtime.tm_gmtoff;
  return 1;
}

#else

static
DYNAMIC_TIME_ZONE_INFORMATION
local_timezone()
{
  DYNAMIC_TIME_ZONE_INFORMATION tz;
  GetDynamicTimeZoneInformation(&tz);
  return tz;
}

static
int
offset(const time_t time, int* output)
{
  struct tm localtime;
  if (localtime_s(&localtime, &time))
    return 0;
  struct tm* gmt = gmtime(&time);
  gmt->tm_isdst = localtime.tm_isdst;
  time_t gmt_time = mktime(gmt);
  if (gmt_time == -1)
    return 0;
  *output = difftime(time, gmt_time);
  return 1;
}

#endif

CAMLprim
value
ocaml_timmy_offset_timestamp_s(value datetime)
{
  CAMLparam1(datetime);
  const time_t time = Int64_val(datetime);
  int offset_timestamp;
  if (!offset(time, &offset_timestamp)) {
    CAMLreturn(Val_none);
  } else {
    CAMLlocal1(res);
    res = caml_alloc_some(Val_int(offset_timestamp));
    CAMLreturn(res);
  }
}

CAMLprim
value
ocaml_timmy_offset_calendar_time_s(value date, value daytime)
{
  CAMLparam2(date, daytime);
  check_tuple(date, 3);
  check_tuple(daytime, 3);

  const int year = check_int(Field(date, 0));
  const int month = check_int(Field(date, 1));
  const int day = check_int(Field(date, 2));
  const int hours = check_int(Field(daytime, 0));
  const int minutes = check_int(Field(daytime, 1));
  const int seconds = check_int(Field(daytime, 2));

  struct tm datetime = {
    .tm_sec = seconds,
    .tm_min = minutes,
    .tm_hour = hours,
    .tm_mday = day,
    .tm_mon = month - 1,
    .tm_year = year - 1900
  };
  time_t time = mktime(&datetime);
  int offset_result;
  if (!offset(time, &offset_result)) {
    CAMLreturn(Val_none);
  } else {
    CAMLlocal1(res);
    res = caml_alloc_some(Val_int(offset_result));
    CAMLreturn(res);
  }
}

#ifndef __MINGW32__

CAMLprim
value
ocaml_timmy_local_timezone_name()
{
  CAMLparam0();
  const time_t now = time(NULL);
  struct tm localtime;
  localtime_r(&now, &localtime);
  CAMLreturn(caml_copy_string (localtime.tm_zone));
}

#else

CAMLprim
value
ocaml_timmy_local_timezone_name()
{
  CAMLparam0();
  const DYNAMIC_TIME_ZONE_INFORMATION tz = local_timezone();
  char output[512];
  wcstombs_s(NULL, output, sizeof(output), tz.TimeZoneKeyName, sizeof(output));
  /* std::wstring_convert<std::codecvt_utf8<wchar_t>> utf8_conv; */
  /* const auto res = utf8_conv.to_bytes(tz.StandardName); */
  CAMLreturn(caml_copy_string(output));
  /* CAMLreturn(caml_copy_string(""));  */
}

#endif
