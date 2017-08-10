# Example iCal schedules

Notes:

* All examples below generated using IceCube
* Timezones are using Ruby timezone IDs, which are not "correct" (should be "America/Los_Angeles" in all below examples)
* The examples need to be wrapped in an iCal "calendar" object to be completely valid

## Daily examples

### Daily

```ical
DTSTART;TZID=PDT:20170810T160000
RRULE:FREQ=DAILY
```

```
2017-08-10 16:00:00 -0700
2017-08-11 16:00:00 -0700
2017-08-12 16:00:00 -0700
...
```

---

### Every 2 days

```ical
DTSTART;TZID=PDT:20170810T160000
RRULE:FREQ=DAILY;INTERVAL=2
```

```
2017-08-10 16:00:00 -0700
2017-08-12 16:00:00 -0700
2017-08-14 16:00:00 -0700
...
```

### Every 2 days / Every 3 days

```ical
DTSTART;TZID=PDT:20170810T160000
RRULE:FREQ=DAILY;INTERVAL=2
RRULE:FREQ=DAILY;INTERVAL=3
```

```
2017-08-10 16:00:00 -0700
2017-08-12 16:00:00 -0700
2017-08-13 16:00:00 -0700
2017-08-14 16:00:00 -0700
2017-08-16 16:00:00 -0700
2017-08-18 16:00:00 -0700
2017-08-19 16:00:00 -0700
...
```

### Daily 3 times

> Note: probably don't need to support this one right away

```ical
DTSTART;TZID=PDT:20170810T160000
RRULE:FREQ=DAILY;COUNT=3
```

```
2017-08-10 16:00:00 -0700
2017-08-11 16:00:00 -0700
2017-08-12 16:00:00 -0700
```

### Daily until August 13, 2017

> Note: IceCube generated the "until" clause at 11pm zulu time for some reason, so the until is "inclusive" in this example

```ical
DTSTART;TZID=PDT:20170810T160000
RRULE:FREQ=DAILY;UNTIL=20170813T230000Z
```

```
2017-08-10 16:00:00 -0700
2017-08-11 16:00:00 -0700
2017-08-12 16:00:00 -0700
2017-08-13 16:00:00 -0700
```

### Daily (with a random one-off time thrown in)

```ical
DTSTART;TZID=PDT:20170810T160000
RRULE:FREQ=DAILY
RDATE;TZID=PDT:20170810T160030
```

```
2017-08-10 16:00:00 -0700
2017-08-10 16:00:30 -0700
2017-08-11 16:00:00 -0700
2017-08-12 16:00:00 -0700
...
```
