using MySqlConnector;
using System;
using Godot;
public partial class sqlc : Node
{
    MySqlConnection conn =new MySqlConnection
        ($"Server=127.0.0.1;User ID=root;Password=Saveliyano!1;Database=geometrybeatdb");
    public bool check_connection(){
        return conn.Ping();
    }
    public Godot.Collections.Array querry(string s)
    {
        Godot.Collections.Array out_=new Godot.Collections.Array();
        try{
            conn.Open();
            using var command = new MySqlCommand(s, conn);
            using var reader = command.ExecuteReader();
            while (reader.Read())
            {
                Godot.Collections.Array data=new Godot.Collections.Array();
                for(int i=0;i<reader.GetColumnSchema().Count;i++){
                    var value=reader.GetValue(i);
                    if(value is UInt32)
                        data.Add(Convert.ToUInt32(value));
                    if (value is UInt64)
                        data.Add(Convert.ToUInt64(value));
                    if (value is UInt16)
                        data.Add(Convert.ToUInt16(value));

                    if (value is Int16)
                        data.Add(Convert.ToInt16(value));
                    if(value is Int32)
                        data.Add(Convert.ToInt32(value));
                    if (value is Int64)
                        data.Add(Convert.ToInt64(value));

                    if (value is string)
                        data.Add(Convert.ToString(value));

                    if (value is float)
                        data.Add((float)(value));

                    if (value is Boolean)
                        data.Add(Convert.ToBoolean(value));

                    if (value is Byte)
                        data.Add(Convert.ToByte(value));

                    if (value is DateTime)
                        data.Add(Convert.ToString(value).Split(" "));
                    if (value is DateOnly)
                        data.Add(Convert.ToString(value).Split(" "));
                    //data.Add(Convert.ToString(value));
                }
                out_.Add(data);
            }
            conn.Close();
            return out_;
        }
        catch(Exception ex)
        {
            GD.Print(s);
            GD.Print(ex.Message);
            return out_;
        }
    }
}