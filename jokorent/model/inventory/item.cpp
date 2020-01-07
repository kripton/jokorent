#include "item.h"

#include <QMetaEnum>
#include <QTextStream>

Item::Item() :
    mModel(0),
    mSerial(),
    mDateBought()
{
}

Item::Item(int model, const QString &serial, const QDateTime &dateBought) :
    mModel(model),
    mSerial(serial),
    mDateBought(dateBought)
{
}

int Item::model() const
{
    return mModel;
}

void Item::setModel(const int model)
{
    mModel = model;
}

QString Item::serial() const
{
    return mSerial;
}

void Item::setSerial(const QString &serial)
{
    mSerial = serial;
}

QDateTime Item::dateBought() const
{
    return mDateBought;
}

void Item::setDateBought(const QDateTime &dateBought)
{
    mDateBought = dateBought;
}

void Item::read(const QJsonObject &json)
{
    if (json.contains("model"))
        mModel = json["model"].toInt();

    if (json.contains("serial") && json["serial"].isString())
        mSerial = json["serial"].toString();

    if (json.contains("dateBought") && json["dateBought"].isString())
        mDateBought = QDateTime::fromString(json["dateBought"].toString(), Qt::ISODate);
}

void Item::write(QJsonObject &json) const
{
    json["model"] = mModel;
    json["serial"] = mSerial;
    json["dateBought"] = mDateBought.toString(Qt::ISODate);
}

void Item::print(int indentation) const
{
    const QString indent(indentation * 2, ' ');
    QTextStream(stdout) << indent << "Model:\t" << mModel << "\n";
    QTextStream(stdout) << indent << "Serial:\t" << mSerial << "\n";
    QTextStream(stdout) << indent << "Date bought:\t" << mDateBought.toString(Qt::ISODate) << "\n";
}
