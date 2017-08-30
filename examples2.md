# Schedules

Some examples of complex schedules and the corresponding iCalendar blocks + ice_cube validations hash + ice_cube output.

## Yearly on the 13th day of the month on Fridays in October

* [ ] supported? (yearly interval yet; no day of month yet; no month of year yet)

```
DTSTART;TZID=PST:20170101T060000
RRULE:FREQ=YEARLY;BYMONTHDAY=13;BYDAY=FR;BYMONTH=10
```

```
{
  :interval=>[#<IceCube::Validations::YearlyInterval::Validation:0x007ff553b04ac8 @interval=1>],
  :base_hour=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff553aff780 @type=:hour>],
  :base_min=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff553afe970 @type=:min>],
  :base_sec=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff553afe740 @type=:sec>],
  :day_of_month=>[#<IceCube::Validations::DayOfMonth::Validation:0x007ff553afd818 @day=13>],
  :day=>[#<IceCube::Validations::Day::Validation:0x007ff553afca80 @day=5>],
  :month_of_year=>[#<IceCube::Validations::MonthOfYear::Validation:0x007ff553af7148 @month=10>]
}
```

```
[
  Fri, 13 Oct 2017 06:00:00 PDT -07:00,
  Fri, 13 Oct 2023 06:00:00 PDT -07:00,
  Fri, 13 Oct 2028 06:00:00 PDT -07:00,
  Fri, 13 Oct 2034 06:00:00 PDT -07:00,
  Fri, 13 Oct 2045 06:00:00 PST -08:00,
  Fri, 13 Oct 2051 06:00:00 PST -08:00,
  Fri, 13 Oct 2056 06:00:00 PST -08:00,
  Fri, 13 Oct 2062 06:00:00 PST -08:00,
  Fri, 13 Oct 2073 06:00:00 PST -08:00,
  Fri, 13 Oct 2079 06:00:00 PST -08:00
]
```

---

## Every 2 days on the 1st Tuesday and last Tuesday and 2nd Wednesday

* [ ] supported? (no day of week support yet)

This one is super weird, because it skips the day if it's not a multiple of 2 from the start time. This example makes more sense if you use the monthly frequency.

```
DTSTART;TZID=PST:20170101T060000
RRULE:FREQ=DAILY;INTERVAL=2;BYDAY=1TU,-1TU,2WE
```

```
{
  :interval=>[#<IceCube::Validations::DailyInterval::Validation:0x007ff55393ece8 @interval=2>],
  :base_hour=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff55393eab8 @type=:hour>],
  :base_min=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff55393e9f0 @type=:min>],
  :base_sec=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff55393e900 @type=:sec>],
  :day_of_week=>[
    #<IceCube::Validations::DayOfWeek::Validation:0x007ff55393e810 @day=2, @occ=1>,
    #<IceCube::Validations::DayOfWeek::Validation:0x007ff55393e608 @day=2, @occ=-1>,
    #<IceCube::Validations::DayOfWeek::Validation:0x007ff55393e5b8 @day=3, @occ=2>
  ]
}
```

```
[
  Tue, 03 Jan 2017 06:00:00 PST -08:00,
  Wed, 11 Jan 2017 06:00:00 PST -08:00,
  Tue, 31 Jan 2017 06:00:00 PST -08:00,
  Wed, 08 Feb 2017 06:00:00 PST -08:00,
  Tue, 28 Feb 2017 06:00:00 PST -08:00,
  Wed, 08 Mar 2017 06:00:00 PST -08:00,
  Tue, 28 Mar 2017 06:00:00 PDT -07:00,
  Tue, 25 Apr 2017 06:00:00 PDT -07:00,
  Tue, 06 Jun 2017 06:00:00 PDT -07:00,
  Wed, 14 Jun 2017 06:00:00 PDT -07:00
]
```

---

## Every 2 weeks on Mondays and Tuesdays

* [x] supported? (yay!)

```
DTSTART;TZID=PST:20170101T060000
RRULE:FREQ=WEEKLY;INTERVAL=2;WKST=SU;BYDAY=MO,TU
```

```
{
  :interval=>[#<IceCube::Validations::WeeklyInterval::Validation:0x007ff553d7f050 @interval=2, @week_start=:sunday>],
  :base_hour=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff553d7ea60 @type=:hour>],
  :base_min=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff553d7e768 @type=:min>],
  :base_sec=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff553d7e4e8 @type=:sec>],
  :day=>[
    #<IceCube::Validations::Day::Validation:0x007ff553d7e0b0 @day=1>,
    #<IceCube::Validations::Day::Validation:0x007ff553d7dfc0 @day=2>
  ]
}
```

```
[
  Mon, 02 Jan 2017 06:00:00 PST -08:00,
  Tue, 03 Jan 2017 06:00:00 PST -08:00,
  Mon, 16 Jan 2017 06:00:00 PST -08:00,
  Tue, 17 Jan 2017 06:00:00 PST -08:00,
  Mon, 30 Jan 2017 06:00:00 PST -08:00,
  Tue, 31 Jan 2017 06:00:00 PST -08:00,
  Mon, 13 Feb 2017 06:00:00 PST -08:00,
  Tue, 14 Feb 2017 06:00:00 PST -08:00,
  Mon, 27 Feb 2017 06:00:00 PST -08:00,
  Tue, 28 Feb 2017 06:00:00 PST -08:00
]
```

---

## Every 2 months on the 1st and last days of the month

* [ ] supported? (no monthly interval yet; no day of month yet)

```
DTSTART;TZID=PST:20170101T060000
RRULE:FREQ=MONTHLY;INTERVAL=2;BYMONTHDAY=1,-1
```

```
{
  :interval=>[#<IceCube::Validations::MonthlyInterval::Validation:0x007ff553aa6068 @interval=2>],
  :base_hour=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff553aa42e0 @type=:hour>],
  :base_min=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff553a9fec0 @type=:min>],
  :base_sec=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff553a9fcb8 @type=:sec>],
  :day_of_month=>[
    #<IceCube::Validations::DayOfMonth::Validation:0x007ff553a9f9c0 @day=1>,
    #<IceCube::Validations::DayOfMonth::Validation:0x007ff553a9f970 @day=-1>
  ]
}
```

```
[
  Sun, 01 Jan 2017 06:00:00 PST -08:00,
  Tue, 31 Jan 2017 06:00:00 PST -08:00,
  Wed, 01 Mar 2017 06:00:00 PST -08:00,
  Fri, 31 Mar 2017 06:00:00 PDT -07:00,
  Mon, 01 May 2017 06:00:00 PDT -07:00,
  Wed, 31 May 2017 06:00:00 PDT -07:00,
  Sat, 01 Jul 2017 06:00:00 PDT -07:00,
  Mon, 31 Jul 2017 06:00:00 PDT -07:00,
  Fri, 01 Sep 2017 06:00:00 PDT -07:00,
  Sat, 30 Sep 2017 06:00:00 PDT -07:00
]
```

---

## Every 2 months on the 1st Monday and last Tuesday

* [ ] supported? (no monthly interval yet)

```
DTSTART;TZID=PST:20170101T060000
RRULE:FREQ=MONTHLY;INTERVAL=2;BYDAY=1MO,-1TU
```

```
{
  :interval=>[#<IceCube::Validations::MonthlyInterval::Validation:0x007ff553c26370 @interval=2>],
  :base_hour=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff553c26050 @type=:hour>],
  :base_min=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff553c25fb0 @type=:min>],
  :base_sec=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff553c25f10 @type=:sec>],
  :day_of_week=>[
    #<IceCube::Validations::DayOfWeek::Validation:0x007ff553c25df8 @day=1, @occ=1>,
    #<IceCube::Validations::DayOfWeek::Validation:0x007ff553c25d80 @day=2, @occ=-1>
  ]
}
```

```
[
  Mon, 02 Jan 2017 06:00:00 PST -08:00,
  Tue, 31 Jan 2017 06:00:00 PST -08:00,
  Mon, 06 Mar 2017 06:00:00 PST -08:00,
  Tue, 28 Mar 2017 06:00:00 PDT -07:00,
  Mon, 01 May 2017 06:00:00 PDT -07:00,
  Tue, 30 May 2017 06:00:00 PDT -07:00,
  Mon, 03 Jul 2017 06:00:00 PDT -07:00,
  Tue, 25 Jul 2017 06:00:00 PDT -07:00,
  Mon, 04 Sep 2017 06:00:00 PDT -07:00,
  Tue, 26 Sep 2017 06:00:00 PDT -07:00
]
```

---

## Every 4 years on the last day of the year

* [ ] supported? (no yearly interval yet; no day of year yet)

```
DTSTART;TZID=PST:20170101T060000
RRULE:FREQ=YEARLY;INTERVAL=4;BYYEARDAY=-1
```

```
{
  :interval=>[#<IceCube::Validations::YearlyInterval::Validation:0x007ff55489f548 @interval=4>],
  :base_hour=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff55489ee90 @type=:hour>],
  :base_min=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff55489ed50 @type=:min>],
  :base_sec=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff55489ec38 @type=:sec>],
  :day_of_year=>[#<IceCube::Validations::DayOfYear::Validation:0x007ff55489ea08 @day=-1>]
}
```

```
[
  Sun, 31 Dec 2017 06:00:00 PST -08:00,
  Fri, 31 Dec 2021 06:00:00 PST -08:00,
  Wed, 31 Dec 2025 06:00:00 PST -08:00,
  Mon, 31 Dec 2029 06:00:00 PST -08:00,
  Sat, 31 Dec 2033 06:00:00 PST -08:00,
  Thu, 31 Dec 2037 06:00:00 PST -08:00,
  Tue, 31 Dec 2041 06:00:00 PST -08:00,
  Sun, 31 Dec 2045 06:00:00 PST -08:00,
  Fri, 31 Dec 2049 06:00:00 PST -08:00,
  Wed, 31 Dec 2053 06:00:00 PST -08:00
]
```

---

## Yearly in January and February

* [ ] supported? (no yearly interval yet; no month of year yet)

```
DTSTART;TZID=PST:20170101T060000
RRULE:FREQ=YEARLY;BYMONTH=1,2
```

```
{
  :interval=>[#<IceCube::Validations::YearlyInterval::Validation:0x007ff5531a69e0 @interval=1>],
  :base_day=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff55319db38 @type=:day>],
  :base_hour=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff55319d750 @type=:hour>],
  :base_min=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff55319d200 @type=:min>],
  :base_sec=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff55319c9b8 @type=:sec>],
  :month_of_year=>[
    #<IceCube::Validations::MonthOfYear::Validation:0x007ff553853d38 @month=1>,
    #<IceCube::Validations::MonthOfYear::Validation:0x007ff553853bf8 @month=2>
  ]
}
```

```
[
  Sun, 01 Jan 2017 06:00:00 PST -08:00,
  Wed, 01 Feb 2017 06:00:00 PST -08:00,
  Mon, 01 Jan 2018 06:00:00 PST -08:00,
  Thu, 01 Feb 2018 06:00:00 PST -08:00,
  Tue, 01 Jan 2019 06:00:00 PST -08:00,
  Fri, 01 Feb 2019 06:00:00 PST -08:00,
  Wed, 01 Jan 2020 06:00:00 PST -08:00,
  Sat, 01 Feb 2020 06:00:00 PST -08:00,
  Fri, 01 Jan 2021 06:00:00 PST -08:00,
  Mon, 01 Feb 2021 06:00:00 PST -08:00
]
```

---

## Every 2 hours on Mondays

* [ ] supported? (bug: starts at 06:00 on Jan 2 instead of at 00:00)

```
DTSTART;TZID=PST:20170101T060000
RRULE:FREQ=HOURLY;INTERVAL=2;BYDAY=MO
```

```
{
  :interval=>[#<IceCube::Validations::HourlyInterval::Validation:0x007ff553b2c078 @interval=2>],
  :base_min=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff553b8ef48 @type=:min>],
  :base_sec=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff553b8ee08 @type=:sec>],
  :day=>[#<IceCube::Validations::Day::Validation:0x007ff553b8eb60 @day=1>]
}
```

```
[
  Mon, 02 Jan 2017 00:00:00 PST -08:00,
  Mon, 02 Jan 2017 02:00:00 PST -08:00,
  Mon, 02 Jan 2017 04:00:00 PST -08:00,
  Mon, 02 Jan 2017 06:00:00 PST -08:00,
  Mon, 02 Jan 2017 08:00:00 PST -08:00,
  Mon, 02 Jan 2017 10:00:00 PST -08:00,
  Mon, 02 Jan 2017 12:00:00 PST -08:00,
  Mon, 02 Jan 2017 14:00:00 PST -08:00,
  Mon, 02 Jan 2017 16:00:00 PST -08:00,
  Mon, 02 Jan 2017 18:00:00 PST -08:00,
  Mon, 02 Jan 2017 20:00:00 PST -08:00,
  Mon, 02 Jan 2017 22:00:00 PST -08:00,
  Mon, 09 Jan 2017 00:00:00 PST -08:00,
  Mon, 09 Jan 2017 02:00:00 PST -08:00,
  Mon, 09 Jan 2017 04:00:00 PST -08:00,
  Mon, 09 Jan 2017 06:00:00 PST -08:00,
  Mon, 09 Jan 2017 08:00:00 PST -08:00,
  Mon, 09 Jan 2017 10:00:00 PST -08:00,
  Mon, 09 Jan 2017 12:00:00 PST -08:00,
  Mon, 09 Jan 2017 14:00:00 PST -08:00
]
```

---

## Every 90 minutes on the last Tuesday

* [ ] supported? (no day of week support yet)

```
DTSTART;TZID=PST:20170101T060000
RRULE:FREQ=MINUTELY;INTERVAL=90;BYDAY=-1TU
```

```
{
  :interval=>[#<IceCube::Validations::MinutelyInterval::Validation:0x007ff55380a368 @interval=90>],
  :base_sec=>[#<IceCube::Validations::ScheduleLock::Validation:0x007ff553809e40 @type=:sec>],
  :day_of_week=>[#<IceCube::Validations::DayOfWeek::Validation:0x007ff553809d00 @day=2, @occ=-1>]
}
```

```
[
  Tue, 31 Jan 2017 00:00:00 PST -08:00,
  Tue, 31 Jan 2017 01:30:00 PST -08:00,
  Tue, 31 Jan 2017 03:00:00 PST -08:00,
  Tue, 31 Jan 2017 04:30:00 PST -08:00,
  Tue, 31 Jan 2017 06:00:00 PST -08:00,
  Tue, 31 Jan 2017 07:30:00 PST -08:00,
  Tue, 31 Jan 2017 09:00:00 PST -08:00,
  Tue, 31 Jan 2017 10:30:00 PST -08:00,
  Tue, 31 Jan 2017 12:00:00 PST -08:00,
  Tue, 31 Jan 2017 13:30:00 PST -08:00,
  Tue, 31 Jan 2017 15:00:00 PST -08:00,
  Tue, 31 Jan 2017 16:30:00 PST -08:00,
  Tue, 31 Jan 2017 18:00:00 PST -08:00,
  Tue, 31 Jan 2017 19:30:00 PST -08:00,
  Tue, 31 Jan 2017 21:00:00 PST -08:00,
  Tue, 31 Jan 2017 22:30:00 PST -08:00,
  Tue, 28 Feb 2017 00:00:00 PST -08:00,
  Tue, 28 Feb 2017 01:30:00 PST -08:00,
  Tue, 28 Feb 2017 03:00:00 PST -08:00,
  Tue, 28 Feb 2017 04:30:00 PST -08:00
]
```

---

## Every 666 seconds on the 12th hour of the day

* [x] supported? (yay!)

```
DTSTART;TZID=PST:20170101T060000
RRULE:FREQ=SECONDLY;INTERVAL=666;BYHOUR=12
```

```
{
  :interval=>[#<IceCube::Validations::SecondlyInterval::Validation:0x007ff553bacb60 @interval=666>],
  :hour_of_day=>[#<IceCube::Validations::HourOfDay::Validation:0x007ff553bac750 @hour=12>]
}
```

```
[
  Sun, 01 Jan 2017 12:06:18 PST -08:00,
  Sun, 01 Jan 2017 12:17:24 PST -08:00,
  Sun, 01 Jan 2017 12:28:30 PST -08:00,
  Sun, 01 Jan 2017 12:39:36 PST -08:00,
  Sun, 01 Jan 2017 12:50:42 PST -08:00,
  Mon, 02 Jan 2017 12:09:18 PST -08:00,
  Mon, 02 Jan 2017 12:20:24 PST -08:00,
  Mon, 02 Jan 2017 12:31:30 PST -08:00,
  Mon, 02 Jan 2017 12:42:36 PST -08:00,
  Mon, 02 Jan 2017 12:53:42 PST -08:00
]
```
