// SPDX-License-Identifier: GPL-2.0-or-later
// PDX-FileCopyrightText: 2023 Mathis <mbb@kaidan.im>

#include "about.h"

KAboutData AboutType::aboutData() const
{
    return KAboutData::applicationData();
}
