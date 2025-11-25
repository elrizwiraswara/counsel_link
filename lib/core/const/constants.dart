import 'package:flutter/material.dart';

import '../../data/models/schedule/schedule_model.dart';
import '../../data/models/user/gender_model.dart';
import '../themes/app_colors.dart';

final counselorAddress = 'Dumai City Counseling office on Jl. Puteri Tujuh, Teluk Binjai, East Dumai';

final List<MenuItemModel> conselingMedium = [
  MenuItemModel(id: 'online', name: 'Online'),
  MenuItemModel(id: 'offline', name: 'Offline'),
];

final List<MenuItemModel> genderMenuItems = [
  MenuItemModel(id: 'male', name: 'Male'),
  MenuItemModel(id: 'female', name: 'Female'),
];

final List<MenuItemModel> religionMenuItems = [
  MenuItemModel(id: 'islam', name: 'Islam'),
  MenuItemModel(id: 'protestant', name: 'Protestant'),
  MenuItemModel(id: 'catholic', name: 'Catholic'),
  MenuItemModel(id: 'hindu', name: 'Hindu'),
  MenuItemModel(id: 'buddha', name: 'Buddha'),
  MenuItemModel(id: 'confucianism', name: 'Confucianism'),
];

String scheduleStatusName(ScheduleStatus? status) {
  switch (status) {
    case ScheduleStatus.created:
      // created
      return 'Waiting Confirmation';
    case ScheduleStatus.confirmed:
      // confirmed
      return 'Schedule Confirmed';
    case ScheduleStatus.unconfirmed:
      // unconfirmed
      return 'Schedule Unconfirmed';
    case ScheduleStatus.done:
      // complete
      return 'Completed';
    case ScheduleStatus.cancelled:
      // cancelled
      return 'Cancelled';
    default:
      return 'Waiting Confirmation';
  }
}

Color scheduleStatusColor(ScheduleStatus? status) {
  switch (status) {
    case ScheduleStatus.created:
      return AppColors.blackLv1;
    case ScheduleStatus.confirmed:
      return AppColors.blackLv1;
    case ScheduleStatus.unconfirmed:
      return AppColors.redLv1;
    case ScheduleStatus.done:
      return AppColors.greenLv1;
    case ScheduleStatus.cancelled:
      return AppColors.redLv1;
    default:
      return AppColors.blackLv1;
  }
}

List<Map<String, dynamic>> locationData = [
  {
    "id": "0",
    "name": "Kota Dumai",
    "district": [
      {
        "id": "1",
        "name": "Dumai Barat",
        "village": [
          {
            "id": "11",
            "name": "Bagan Keladi",
          },
          {
            "id": "12",
            "name": "Pangkalan Sesai",
          },
          {
            "id": "13",
            "name": "Purnama",
          },
          {
            "id": "14",
            "name": "Simpang Tetap Darul Ichsan",
          },
        ],
      },
      {
        "id": "2",
        "name": "Dumai Timur",
        "village": [
          {
            "id": "21",
            "name": "Bukit Batrem",
          },
          {
            "id": "22",
            "name": "Buluh Kasap",
          },
          {
            "id": "23",
            "name": "Jaya Mukti",
          },
          {
            "id": "24",
            "name": "Tanjung Palas",
          },
          {
            "id": "25",
            "name": "Teluk Binjai",
          },
        ],
      },
      {
        "id": "3",
        "name": "Bukit Kapur",
        "village": [
          {
            "id": "31",
            "name": "Bagan Besar",
          },
          {
            "id": "32",
            "name": "Bukit Kayu Kapur",
          },
          {
            "id": "33",
            "name": "Bukit Nenas",
          },
          {
            "id": "34",
            "name": "Gurun Panjang",
          },
          {
            "id": "35",
            "name": "Kampung Baru",
          },
          {
            "id": "36",
            "name": "Bagan Besar Timur",
          },
          {
            "id": "37",
            "name": "Bukit Kapur",
          },
        ],
      },
      {
        "id": "4",
        "name": "Sungai Sembilan",
        "village": [
          {
            "id": "41",
            "name": "Bangsal Aceh",
          },
          {
            "id": "42",
            "name": "Basilam Baru",
          },
          {
            "id": "43",
            "name": "Batu Teritip",
          },
          {
            "id": "44",
            "name": "Lubuk Gaung",
          },
          {
            "id": "45",
            "name": "Tanjung Penyembal",
          },
          {
            "id": "46",
            "name": "Sungai Geniot",
          },
        ],
      },
      {
        "id": "5",
        "name": "Medang Kampai",
        "village": [
          {
            "id": "51",
            "name": "Guntung",
          },
          {
            "id": "52",
            "name": "Mundam",
          },
          {
            "id": "53",
            "name": "Pelintung",
          },
          {
            "id": "54",
            "name": "Teluk Makmur",
          },
        ],
      },
      {
        "id": "6",
        "name": "Dumai Kota",
        "village": [
          {
            "id": "61",
            "name": "Rimba Sekampung",
          },
          {
            "id": "62",
            "name": "Laksamana",
          },
          {
            "id": "63",
            "name": "Dumai Kota",
          },
          {
            "id": "64",
            "name": "Bintan",
          },
          {
            "id": "65",
            "name": "Sukajadi",
          },
        ],
      },
      {
        "id": "7",
        "name": "Dumai Selatan",
        "village": [
          {
            "id": "71",
            "name": "Bukit Datuk",
          },
          {
            "id": "72",
            "name": "Mekar Sari",
          },
          {
            "id": "7",
            "name": "Bukit Timah",
          },
          {
            "id": "74",
            "name": "Ratu Sima",
          },
          {
            "id": "75",
            "name": "Bumi Ayu",
          },
        ],
      },
    ],
  },
];
