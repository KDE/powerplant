// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: MIT

#include "colorgradientinterpolator.h"
#include <QQmlInfo>

constexpr int stepCount = 1000;

ColorGradientInterpolator::ColorGradientInterpolator(QObject *parent)
    : QObject(parent)
{
    m_gradient.setEasingCurve(QEasingCurve::Linear);
    m_gradient.setDuration(stepCount);

    connect(this, &ColorGradientInterpolator::progressChanged, this, &ColorGradientInterpolator::colorChanged);
    connect(this, &ColorGradientInterpolator::gradientStopsChanged, this, &ColorGradientInterpolator::colorChanged);
}

QColor ColorGradientInterpolator::color() const
{
    return m_gradient.currentValue().value<QColor>();
}

double ColorGradientInterpolator::progress() const
{
    return m_progress;
}

void ColorGradientInterpolator::setProgress(const double progress)
{
    const auto boundedProgress = qBound(0.0, progress, 1.0);

    if (boundedProgress == m_progress) {
        return;
    }

    m_progress = boundedProgress;
    m_gradient.setCurrentTime(m_progress * stepCount);
    Q_EMIT progressChanged();
}

QVariantList ColorGradientInterpolator::gradientStops() const
{
    return {};
}

void ColorGradientInterpolator::setGradientStops(const QVariantList &gradientStops)
{
    QVariantAnimation::KeyValues keyValues;
    for (const auto &gradientStop : gradientStops) {
        const auto map = gradientStop.toMap();
        bool ok = true;
        auto position = map[QStringLiteral("position")].toFloat(&ok);
        if (position > 1.0 || position < 0.0 || !ok) {
            qmlWarning(this) << "Invalid position given" << map[QStringLiteral("position")];
        }

        auto color = QColor(map[QStringLiteral("color")].toString());
        if (!color.isValid()) {
            qmlWarning(this) << "Invalid color given" << map[QStringLiteral("color")];
        }

        keyValues.append({position, color});
    }

    m_gradient.setKeyValues(keyValues);
    Q_EMIT gradientStopsChanged();
}

#include "moc_colorgradientinterpolator.cpp"
