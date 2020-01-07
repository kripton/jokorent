#ifndef ITEM_H
#define ITEM_H

#include <QJsonObject>
#include <QObject>
#include <QString>
#include <QDateTime>

class Item
{
    Q_GADGET

public:
    Item();
    Item(int model, const QString &serial, const QDateTime &dateBought);

    int model() const;
    void setModel(int id);

    QString serial() const;
    void setSerial(const QString &serial);

    QDateTime dateBought() const;
    void setDateBought(const QDateTime &dateBought);

    void read(const QJsonObject &json);
    void write(QJsonObject &json) const;

    void print(int indentation = 0) const;

private:
    int mModel;
    QString mSerial;
    QDateTime mDateBought;
};

#endif // ITEM_H
