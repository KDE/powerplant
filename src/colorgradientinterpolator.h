// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: MIT

#pragma once

#include <QColor>
#include <QObject>
#include <QVariantAnimation>
#include <QtQml>

class ColorGradientInterpolator : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(ColorInterpolator)
    Q_PROPERTY(QColor color READ color NOTIFY colorChanged)
    Q_PROPERTY(double progress READ progress WRITE setProgress NOTIFY progressChanged)
    Q_PROPERTY(QVariantList gradientStops READ gradientStops WRITE setGradientStops NOTIFY gradientStopsChanged)

public:
    explicit ColorGradientInterpolator(QObject *parent = nullptr);

    QColor color() const;

    double progress() const;
    void setProgress(const double progress);

    QVariantList gradientStops() const;
    void setGradientStops(const QVariantList &gradientStops);

Q_SIGNALS:
    void progressChanged();
    void gradientStopsChanged();
    void colorChanged();

private:
    double m_progress = 0.0;
    QVariantAnimation m_gradient;
};