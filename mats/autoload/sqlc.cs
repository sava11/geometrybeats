using MySqlConnector;
using System;
using Godot;

public partial class sqlc : Node
{
    private MySqlConnection _connection;

    public override void _Ready()
    {
        var connectionString = "Server=127.0.0.1;User ID=root;Password=Saveliyano!1;Database=geometrybeatdb;";
        //"Server=junction.proxy.rlwy.net;Port=35510;User ID=root;Password=SThpFvJhaOYpSYayhhDfGeXAdbhxGxpp;Database=geometrybeatdb;SslMode=Required;"
        _connection = new MySqlConnection(connectionString);
    }

    public bool CheckConnection()
    {
        try
        {
            if (_connection.State != System.Data.ConnectionState.Open)
            {
                _connection.Open();
                return true;
            }
            return _connection.Ping();
        }
        catch (Exception ex)
        {
            LogError("CheckConnection", ex.Message);
            return false;
        }
    }

    public Godot.Collections.Array query(string sql)
    {
        Godot.Collections.Array result = new Godot.Collections.Array();

        try
        {
            if (_connection.State != System.Data.ConnectionState.Open)
            {
                _connection.Open();
            }

            using (var command = new MySqlCommand(sql, _connection))
            using (var reader = command.ExecuteReader())
            {
                while (reader.Read())
                {
                    Godot.Collections.Array row = new Godot.Collections.Array();
                    for (int i = 0; i < reader.FieldCount; i++)
                    {
                        var value = reader.GetValue(i);

                        if (value == DBNull.Value)
                        {
                            row.Add(GD.StrToVar("null")); // Обработка пустых значений
                        }
                        else
                        {
                            if(value is UInt32)
                        row.Add(Convert.ToUInt32(value));
                    if (value is UInt64)
                        row.Add(Convert.ToUInt64(value));
                    if (value is UInt16)
                        row.Add(Convert.ToUInt16(value));

                    if (value is Int16)
                        row.Add(Convert.ToInt16(value));
                    if(value is Int32)
                        row.Add(Convert.ToInt32(value));
                    if (value is Int64)
                        row.Add(Convert.ToInt64(value));

                    if (value is string)
                        row.Add(Convert.ToString(value));

                    if (value is float)
                        row.Add((float)(value));

                    if (value is Boolean)
                        row.Add(Convert.ToBoolean(value));

                    if (value is Byte)
                        row.Add(Convert.ToByte(value));

                    if (value is DateTime)
                        row.Add(Convert.ToString(value).Split(" "));
                    if (value is DateOnly)
                        row.Add(Convert.ToString(value).Split(" "));
                        }
                    }

                    result.Add(row);
                }
            }
        }
        catch (Exception ex)
        {
            LogError(sql, ex.Message);
        }
        finally
        {
            if (_connection.State == System.Data.ConnectionState.Open)
            {
                _connection.Close();
            }
        }

        return result;
    }

    private void LogError(string query, string message)
    {
        GD.PrintErr($"[SQL ERROR] Query: {query}");
        GD.PrintErr($"[SQL ERROR] Message: {message}");
    }
}