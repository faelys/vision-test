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

with AWS.Config;
with AWS.Messages;
with AWS.Parameters;
with AWS.Response;
with AWS.Server;
with AWS.Status;
with Vision.Engine;

package body Vision.Input is

   WS : AWS.Server.HTTP;
   Count : Positive := 1;

   function Handler (Request : in AWS.Status.Data) return AWS.Response.Data;

   function Form_Page return AWS.Response.Data;
   function Invalid_Input return AWS.Response.Data;



   function Handler (Request : in AWS.Status.Data) return AWS.Response.Data is
      URI : constant String := AWS.Status.URI (Request);
   begin
      if URI = "/" then
         return Form_Page;
      elsif URI = "/entry" then
         declare
            P : constant AWS.Parameters.List
              := AWS.Status.Parameters (Request);
            Img : constant String := AWS.Parameters.Get (P, "direction");
            D : Directions.Enum;
         begin
            begin
               D := Directions.Enum'Value (Img);
            exception
               when Constraint_Error =>
                  return Invalid_Input;
            end;

            Engine.User_Input (D);
            Count := Count + 1;
         end;
         return AWS.Response.URL (Location => "/");
      else
         return AWS.Response.Acknowledge
           (AWS.Messages.S404, "<p>Page '" & URI & "' Not found.");
      end if;
   end Handler;


   procedure Start is
   begin
      AWS.Server.Start (WS, Handler'Access, AWS.Config.Get_Current);
   end Start;


   procedure Stop is
   begin
      AWS.Server.Shutdown (WS);
   end Stop;


   function Form_Page return AWS.Response.Data is
   begin
      return AWS.Response.Build ("text/html",
        "<html><head><title>Vision Test</title><style>"
        & "input { font-size: 1000%; text-align: center; "
           & "width: 1.2em; height: 1.2em }"
        & "</style></head><body>"
        & "<h1>Vision Test</h1><p>Test"
        & Positive'Image (Count) & "</p><table><tr><td></td>"
        & "<td><form method=""POST"" action=""/entry"">"
           & "<input name=""direction"" value=""north"" type=""hidden"">"
           & "<input type=""submit"" value=""m"">"
           & "</form></td><td></td></tr><tr>"
        & "<td><form method=""POST"" action=""/entry"">"
           & "<input name=""direction"" value=""west"" type=""hidden"">"
           & "<input type=""submit"" value=""E"">"
           & "</form></td><td></td>"
        & "<td><form method=""POST"" action=""/entry"">"
           & "<input name=""direction"" value=""east"" type=""hidden"">"
           & "<input type=""submit"" value=""&#8707"">"
           & "</form></td></tr><tr><td></td>"
        & "<td><form method=""POST"" action=""/entry"">"
           & "<input name=""direction"" value=""south"" type=""hidden"">"
           & "<input type=""submit"" value=""&#1064"">"
           & "</form></td><td></td></tr>"
        & "</table></body></html>");
   end Form_Page;


   function Invalid_Input return AWS.Response.Data is
   begin
      return AWS.Response.Build ("text/plain", "Invalid input");
   end Invalid_Input;
end Vision.Input;
