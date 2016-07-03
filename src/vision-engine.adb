------------------------------------------------------------------------------
-- Copyright (c) 2016, Natacha Porté                                        --
--                                                                          --
-- Permission to use, copy, modify, and distribute this software for any    --
-- purpose with or without fee is hereby granted, provided that the above   --
-- copyright notice and this permission notice appear in all copies.        --
--                                                                          --
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES --
-- WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF         --
-- MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR  --
-- ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES   --
-- WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN    --
-- ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF  --
-- OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.           --
------------------------------------------------------------------------------

with Ada.Characters.Latin_1;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;
with Vision.Display;

package body Vision.Engine is

   package Random_Directions is new Ada.Numerics.Discrete_Random
     (Directions.Enum);

   Image : constant array (Boolean) of Character
     := (True => '1', False => '0');

   Generator : Random_Directions.Generator;
   Float_Generator : Ada.Numerics.Float_Random.Generator;
   Current_Direction : Directions.Enum;
   Current_Size : Detail_Size;

   procedure Renew_Values;



   procedure Start is
   begin
      Random_Directions.Reset (Generator);
      Ada.Numerics.Float_Random.Reset (Float_Generator);
      Renew_Values;
   end Start;


   procedure Stop is null;


   procedure User_Input (Direction : in Directions.Extended) is
      use type Directions.Extended;
   begin
      Ada.Text_IO.Put_Line
        (Detail_Size'Image (Current_Size)
         & Ada.Characters.Latin_1.HT
         & Directions.Enum'Image (Current_Direction)
         & Ada.Characters.Latin_1.HT
         & Directions.Extended'Image (Direction)
         & Ada.Characters.Latin_1.HT
         & Image (Current_Direction = Direction));
      Renew_Values;
   end User_Input;


   procedure Renew_Values is
   begin
      Current_Direction := Random_Directions.Random (Generator);
      Current_Size := Minimum_Size + Detail_Size
        (Float'Floor (Ada.Numerics.Float_Random.Random (Float_Generator)
                        * Float (Maximum_Size - Minimum_Size + 1)));
      Display.Update (Current_Size, Current_Direction);
   end Renew_Values;

end Vision.Engine;
