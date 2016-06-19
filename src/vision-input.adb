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
with AWS.Response;
with AWS.Server;
with AWS.Status;

package body Vision.Input is

   WS : AWS.Server.HTTP;

   function Handler (Request : in AWS.Status.Data) return AWS.Response.Data;



   function Handler (Request : in AWS.Status.Data) return AWS.Response.Data is
      pragma Unreferenced (Request);
   begin
      return AWS.Response.Build ("text/plain", "Work in progress");
   end Handler;


   procedure Start is
   begin
      AWS.Server.Start (WS, Handler'Access, AWS.Config.Get_Current);
   end Start;


   procedure Stop is
   begin
      AWS.Server.Shutdown (WS);
   end Stop;

end Vision.Input;
